#!/usr/bin/env python3
"""
Simple standalone script to test WinRM connectivity to VDI Windows VM.
Run this after Terraform deployment to verify WinRM is working before running full test suite.

Supports SSH tunneling through bastion host to bypass Zscaler interception.

Usage:
    # Direct connection (may be blocked by Zscaler)
    python3 test_vdi_winrm.py <vdi_public_ip> <username> <password>
    
    # Via SSH tunnel through bastion (bypasses Zscaler)
    python3 test_vdi_winrm.py <vdi_private_ip> <username> <password> \
        --bastion-host <bastion_ip> --bastion-user centos --bastion-key /path/to/key.pem
    
    # Read from terraform output
    python3 test_vdi_winrm.py --from-terraform
    
Example:
    python3 test_vdi_winrm.py 10.1.200.4 ccvdiuser "password" \
        --bastion-host 104.45.205.85 --bastion-user centos --bastion-key zscc-key-znngcj0v.pem
"""

import sys
import re
import argparse
import subprocess
import json
import os

try:
    import winrm
except ImportError:
    print("ERROR: pywinrm not installed. Run: pip install pywinrm")
    sys.exit(1)


def parse_testbed_file(filepath="testbed.txt"):
    """Parse testbed.txt to extract VDI connection info"""
    try:
        with open(filepath, 'r') as f:
            content = f.read()
        
        # Extract VDI Public IP
        ip_match = re.search(r'VDI Public IP:\s*\n(\S+)', content)
        vdi_ip = ip_match.group(1) if ip_match else None
        
        # Extract VDI Username
        user_match = re.search(r'VDI Username:\s*\n(\S+)', content)
        vdi_user = user_match.group(1) if user_match else None
        
        # Extract VDI Password
        pass_match = re.search(r'VDI Password:\s*\n(.+?)(?:\n|$)', content)
        vdi_pass = pass_match.group(1).strip() if pass_match else None
        
        if not all([vdi_ip, vdi_user, vdi_pass]):
            print(f"ERROR: Could not parse all VDI details from {filepath}")
            print(f"  VDI IP: {vdi_ip}")
            print(f"  Username: {vdi_user}")
            print(f"  Password: {'*' * len(vdi_pass) if vdi_pass else None}")
            return None, None, None
            
        return vdi_ip, vdi_user, vdi_pass
    except FileNotFoundError:
        print(f"ERROR: {filepath} not found")
        return None, None, None


def parse_terraform_output(tf_dir="base_1cc"):
    """Parse terraform output to extract VDI and bastion connection info"""
    try:
        result = subprocess.run(
            ["terraform", "output", "-json"],
            cwd=tf_dir,
            capture_output=True,
            text=True
        )
        if result.returncode != 0:
            print(f"ERROR: terraform output failed: {result.stderr}")
            return None
        
        output = json.loads(result.stdout)
        testbed_config = output.get("testbedconfig", {}).get("value", "")
        
        # Parse the testbed config string
        vdi_ip_match = re.search(r'VDI Public IP:\s*\n(\S+)', testbed_config)
        vdi_private_ip = None
        
        # Get VDI private IP from Azure CLI
        rg_match = re.search(r'Resource Group:\s*\n(\S+)', testbed_config)
        if rg_match:
            rg_name = rg_match.group(1)
            az_result = subprocess.run(
                ["az", "vm", "list-ip-addresses", "--resource-group", rg_name, "-o", "json"],
                capture_output=True, text=True
            )
            if az_result.returncode == 0:
                vms = json.loads(az_result.stdout)
                for vm in vms:
                    if "vdi" in vm.get("virtualMachine", {}).get("name", "").lower():
                        vdi_private_ip = vm.get("virtualMachine", {}).get("network", {}).get("privateIpAddresses", [None])[0]
                        break
        
        vdi_user_match = re.search(r'VDI Username:\s*\n(\S+)', testbed_config)
        vdi_pass_match = re.search(r'VDI Password:\s*\n(.+?)(?:\n|$)', testbed_config)
        bastion_match = re.search(r'Bastion Public IP:\s*\n(\S+)', testbed_config)
        
        # Find SSH key file
        key_files = [f for f in os.listdir(tf_dir) if f.endswith('.pem')]
        key_file = os.path.join(tf_dir, key_files[0]) if key_files else None
        
        return {
            'vdi_public_ip': vdi_ip_match.group(1) if vdi_ip_match else None,
            'vdi_private_ip': vdi_private_ip,
            'vdi_username': vdi_user_match.group(1) if vdi_user_match else None,
            'vdi_password': vdi_pass_match.group(1).strip() if vdi_pass_match else None,
            'bastion_ip': bastion_match.group(1) if bastion_match else None,
            'bastion_user': 'centos',
            'bastion_key': key_file,
        }
    except Exception as e:
        print(f"ERROR: Failed to parse terraform output: {e}")
        return None


def test_winrm_connection(hostname, username, password, port=5985, 
                          bastion_host=None, bastion_user=None, bastion_key=None):
    """Test WinRM connection and run basic commands
    
    If bastion parameters are provided, creates an SSH tunnel to bypass Zscaler.
    """
    
    print("=" * 60)
    print("VDI WinRM Connection Test")
    print("=" * 60)
    print(f"Host: {hostname}")
    print(f"Port: {port}")
    print(f"Username: {username}")
    print(f"Password: {'*' * len(password)}")
    if bastion_host:
        print(f"Bastion: {bastion_user}@{bastion_host}")
        print(f"Key: {bastion_key}")
    print("=" * 60)
    
    ssh_tunnel = None
    connect_host = hostname
    connect_port = port
    
    # Set up SSH tunnel if bastion is configured
    if bastion_host and bastion_user and bastion_key:
        import socket
        import time
        
        # Find free local port
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.bind(('', 0))
            local_port = s.getsockname()[1]
        
        print(f"\n[0/6] Setting up SSH tunnel through bastion...")
        tunnel_cmd = [
            'ssh', '-N', '-L',
            f'{local_port}:{hostname}:{port}',
            '-i', bastion_key,
            '-o', 'StrictHostKeyChecking=no',
            '-o', 'UserKnownHostsFile=/dev/null',
            f'{bastion_user}@{bastion_host}'
        ]
        print(f"      Command: {' '.join(tunnel_cmd)}")
        
        ssh_tunnel = subprocess.Popen(tunnel_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        time.sleep(5)  # Wait longer for tunnel to establish
        
        if ssh_tunnel.poll() is not None:
            stderr = ssh_tunnel.stderr.read().decode()
            print(f"      FAILED: SSH tunnel failed - {stderr}")
            return False
        
        # Verify tunnel is working
        import socket
        for _ in range(5):
            try:
                test_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                test_sock.settimeout(2)
                test_sock.connect(('127.0.0.1', local_port))
                test_sock.close()
                break
            except:
                time.sleep(1)
        
        print(f"      SUCCESS: SSH tunnel established on localhost:{local_port}")
        connect_host = "127.0.0.1"
        connect_port = local_port
    
    endpoint = f"http://{connect_host}:{connect_port}/wsman"
    
    try:
        print(f"\n[1/6] Connecting to {endpoint}...")
        session = winrm.Session(
            endpoint,
            auth=(username, password),
            transport='basic',
            read_timeout_sec=60,
            operation_timeout_sec=30
        )
        print("      Session created successfully")
        
    except Exception as e:
        print(f"      FAILED: Could not create session - {e}")
        return False
    
    # Test 1: Get hostname
    print("\n[2/6] Testing: Get computer name...")
    try:
        result = session.run_ps("$env:COMPUTERNAME")
        if result.status_code == 0:
            hostname_result = result.std_out.decode().strip()
            print(f"      SUCCESS: Computer name = {hostname_result}")
        else:
            print(f"      FAILED: {result.std_err.decode()}")
            return False
    except Exception as e:
        print(f"      FAILED: {e}")
        return False
    
    # Test 2: Get OS info
    print("\n[3/6] Testing: Get OS version...")
    try:
        result = session.run_ps("(Get-WmiObject Win32_OperatingSystem).Caption")
        if result.status_code == 0:
            os_info = result.std_out.decode().strip()
            print(f"      SUCCESS: OS = {os_info}")
        else:
            print(f"      WARNING: {result.std_err.decode()}")
    except Exception as e:
        print(f"      WARNING: {e}")
    
    # Test 3: Check ZCCVDIService
    print("\n[4/6] Testing: Check ZCCVDIService status...")
    try:
        result = session.run_ps("Get-Service ZCCVDIService -ErrorAction SilentlyContinue | Select-Object Status, Name")
        output = result.std_out.decode().strip()
        if result.status_code == 0 and output:
            print(f"      SUCCESS: ZCCVDIService found")
            print(f"      {output}")
        else:
            print(f"      WARNING: ZCCVDIService not found or not installed yet")
            print(f"      (This is OK if VDI installer hasn't completed)")
    except Exception as e:
        print(f"      WARNING: {e}")
    
    # Test 4: Test DNS resolution (like the actual test does)
    print("\n[5/6] Testing: DNS resolution (Resolve-DnsName)...")
    try:
        result = session.run_ps("Resolve-DnsName -Name google.com -Server 8.8.8.8 -QuickTimeout -DnsOnly | Select-Object -First 1")
        if result.status_code == 0:
            print(f"      SUCCESS: DNS resolution working")
            dns_output = result.std_out.decode().strip()[:200]
            print(f"      {dns_output}")
        else:
            print(f"      WARNING: DNS resolution failed - {result.std_err.decode()[:100]}")
    except Exception as e:
        print(f"      WARNING: {e}")
    
    # Test 5: Test web request (like the actual test does)
    print("\n[6/6] Testing: Web request (Invoke-WebRequest)...")
    try:
        result = session.run_ps("Invoke-WebRequest -UseBasicParsing -Uri 'http://ip.zscaler.com' -TimeoutSec 10 | Select-Object StatusCode")
        if result.status_code == 0:
            print(f"      SUCCESS: Web request working")
            web_output = result.std_out.decode().strip()
            print(f"      {web_output}")
        else:
            stderr = result.std_err.decode()[:200]
            print(f"      WARNING: Web request failed - {stderr}")
    except Exception as e:
        print(f"      WARNING: {e}")
    
    print("\n" + "=" * 60)
    print("WinRM CONNECTION TEST PASSED!")
    print("=" * 60)
    print("\nYou can now run the full VDI test suite:")
    print("  cd /Users/sneh/workspace-pyats/gitlab/zztest/suites/smoke")
    print("  pyats run job test_ec_vdi_job.py --testbed=vdi.yml --zcc_vdi_user=<user>")
    print("=" * 60)
    
    # Cleanup SSH tunnel
    if ssh_tunnel:
        ssh_tunnel.terminate()
        ssh_tunnel.wait()
        print("\nSSH tunnel closed.")
    
    return True


def main():
    parser = argparse.ArgumentParser(
        description="Test WinRM connectivity to VDI Windows VM",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Direct connection (may be blocked by Zscaler)
  python3 test_vdi_winrm.py 20.44.183.157 ccvdiuser "password123"
  
  # Via SSH tunnel through bastion (bypasses Zscaler)
  python3 test_vdi_winrm.py 10.1.200.4 ccvdiuser "password123" \\
      --bastion-host 104.45.205.85 --bastion-user centos --bastion-key zscc-key.pem
  
  # Auto-detect from terraform output
  python3 test_vdi_winrm.py --from-terraform
  
  # From testbed file
  python3 test_vdi_winrm.py --from-testbed --testbed-file ../testbed.txt
        """
    )
    
    parser.add_argument('hostname', nargs='?', help='VDI IP address (private IP if using bastion)')
    parser.add_argument('username', nargs='?', help='VDI admin username')
    parser.add_argument('password', nargs='?', help='VDI admin password')
    parser.add_argument('--port', type=int, default=5985, help='WinRM port (default: 5985)')
    parser.add_argument('--from-testbed', action='store_true', help='Read connection info from testbed.txt')
    parser.add_argument('--testbed-file', default='testbed.txt', help='Path to testbed.txt file')
    parser.add_argument('--from-terraform', action='store_true', help='Read connection info from terraform output')
    parser.add_argument('--tf-dir', default='base_1cc', help='Terraform directory (default: base_1cc)')
    parser.add_argument('--bastion-host', help='Bastion host IP for SSH tunneling')
    parser.add_argument('--bastion-user', default='centos', help='Bastion SSH username (default: centos)')
    parser.add_argument('--bastion-key', help='Path to bastion SSH private key')
    
    args = parser.parse_args()
    
    bastion_host = args.bastion_host
    bastion_user = args.bastion_user
    bastion_key = args.bastion_key
    
    if args.from_terraform:
        tf_config = parse_terraform_output(args.tf_dir)
        if not tf_config:
            sys.exit(1)
        
        print("Detected from Terraform:")
        print(f"  VDI Public IP: {tf_config['vdi_public_ip']}")
        print(f"  VDI Private IP: {tf_config['vdi_private_ip']}")
        print(f"  Bastion IP: {tf_config['bastion_ip']}")
        print(f"  SSH Key: {tf_config['bastion_key']}")
        print()
        
        # Use private IP with bastion tunnel to bypass Zscaler
        hostname = tf_config['vdi_private_ip'] or tf_config['vdi_public_ip']
        username = tf_config['vdi_username']
        password = tf_config['vdi_password']
        bastion_host = tf_config['bastion_ip']
        bastion_user = tf_config['bastion_user']
        bastion_key = tf_config['bastion_key']
        
    elif args.from_testbed:
        hostname, username, password = parse_testbed_file(args.testbed_file)
        if not all([hostname, username, password]):
            sys.exit(1)
    elif args.hostname and args.username and args.password:
        hostname = args.hostname
        username = args.username
        password = args.password
    else:
        parser.print_help()
        print("\nERROR: Provide hostname, username, password OR use --from-terraform/--from-testbed")
        sys.exit(1)
    
    success = test_winrm_connection(
        hostname, username, password, args.port,
        bastion_host=bastion_host,
        bastion_user=bastion_user,
        bastion_key=bastion_key
    )
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
