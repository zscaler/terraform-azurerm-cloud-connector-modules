
locals {
  admin_password = (
    try(
      module.cc_vdi[0].admin_password[0],
      (sensitive("NA"))
    )
  )
  admin_username = (
    try(
      module.cc_vdi[0].admin_username[0],
      "NA"
    )
  )
}

locals {

  testbedconfig = <<TB
***Disclaimer***
By default, these templates store two critical files to the "examples" directory. DO NOT delete/lose these files:
1. Terraform State file (terraform.tfstate) - Terraform must store state about your managed infrastructure and configuration. 
   This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures.

   Terraform uses state to determine which changes to make to your infrastructure. 
   Prior to any operation, Terraform does a refresh to update the state with the real infrastructure.

   If this file is missing, you will NOT be able to make incremental changes to the environment resources without first importing state back to terraform manually.

2. SSH Private Key (.pem) file - Zscaler templates will attempt to create a new local private/public key pair for VM access (if a pre-existing one is not specified). 
   You (and subsequently Zscaler) will NOT be able to remotely access these VMs once deployed without valid SSH access.
***Disclaimer***


1) Copy the SSH key to the bastion host
scp -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.bastion.public_ip}:/home/centos/.

2) SSH to the bastion host
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.bastion.public_ip}

3) SSH to the CC
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem zsroot@${module.cc_vm.private_ip[0]} -o "proxycommand ssh -W %h:%p -i ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.bastion.public_ip}"

4) SSH to the workload host
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.workload.private_ip[0]} -o "proxycommand ssh -W %h:%p -i ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.bastion.public_ip}"

All Workload IPs. Replace private IP below with centos@"ip address" in ssh example command above.
${join("\n", module.workload.private_ip)}


Resource Group: 
${module.network.resource_group_name}

All CC Primary Service IPs:
${join("\n", module.cc_vm.service_ip)}

All NAT GW IPs:
${join("\n", module.network.public_ip_address)}

Bastion Public IP: 
${module.bastion.public_ip}

VDI Public IP:
${try(join("\n", module.cc_vdi[0].public_ip_address), "N/A")}

VDI Username:
${local.admin_username}

VDI Password:
${nonsensitive(local.admin_password)}

TB
}

output "testbedconfig" {
  description = "Azure Testbed results"
  value       = local.testbedconfig
}

resource "local_file" "testbed" {
  content  = local.testbedconfig
  filename = "../testbed.txt"
}

# pyATS Testbed YAML for VDI validation tests
locals {
  vdi_private_ip = try(module.cc_vdi[0].private_ip[0], "N/A")
  vdi_public_ip  = try(module.cc_vdi[0].public_ip_address[0], "N/A")
  
  pyats_testbed = <<-TESTBED
testbed:
  name: ZCC_VDI_Testbed_${random_string.suffix.result}

devices:
  # VDI Windows VM - WinRM connection (not SSH)
  VDI:
    os: windows
    type: windows
    connections:
      defaults:
        class: tests.ec.vdi_validation.winrm_client.WinRMConnector
        via: winrm
      winrm:
        hostname: ${local.vdi_public_ip}
        port: 5985
        username: ${local.admin_username}
        password: "${nonsensitive(local.admin_password)}"
        transport: basic
    custom:
      vdi_client_ip: ${local.vdi_private_ip}
      vdi_hostname: vdi-1-${random_string.suffix.result}
      vdi_user: "vdi-system-user@<your_domain>.zscaler.net"

  # Cloud Connector (EC) - SSH via bastion
  EC:
    os: linux
    type: linux
    connections:
      defaults:
        class: fast.connections.pyats_connector.ZSNodeConnector
        via: fast
      fast:
        hostname: ${module.cc_vm.private_ip[0]}
        port: 22
        username: zsroot
        # Use SSH key authentication via bastion
        # ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem zsroot@${module.cc_vm.private_ip[0]} -o "proxycommand ssh -W %h:%p -i ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.bastion.public_ip}"

  # CC Cloud API - Update with your credentials
  CLOUD:
    os: linux
    type: linux
    connections:
      defaults:
        class: fast.connections.pyats_connector.APIClientConnector
        via: fast
      fast:
        hostname: connector.zscaler.net
        port: 443
        username: "<your_cc_admin_username>"
        password: "<your_cc_admin_password>"
        api_key: "<your_api_key>"
    custom:
      cid: "<your_company_id>"
      loc_name: "${module.network.resource_group_name}"
      ec_group_name: "<your_ec_group_name>"

  # ZIA API - Update with your credentials
  zia:
    os: linux
    type: linux
    connections:
      defaults:
        class: fast.connections.pyats_connector.APIClientConnector
        via: fast
      fast:
        hostname: zsapi.zscaler.net
        port: 443
        username: "<your_zia_admin_username>"
        password: "<your_zia_admin_password>"
        api_key: "<your_zia_api_key>"
        api_base_url: /zsapi/v1
    custom:
      nw_services: []
      proxy_name: "<your_proxy_name>"

  # ZPA API - Update with your credentials
  zpa:
    os: linux
    type: linux
    connections:
      defaults:
        class: fast.connections.pyats_connector.APIClientConnector
        via: fast
      fast:
        hostname: config.private.zscaler.com
        port: 443
        client_id: "<your_zpa_client_id>"
        client_secret: "<your_zpa_client_secret>"
    custom:
      customer_id: "<your_zpa_customer_id>"
TESTBED
}

resource "local_file" "pyats_testbed" {
  count    = var.deploy_cca_vdi ? 1 : 0
  content  = local.pyats_testbed
  filename = "../pyats_testbed.yaml"
}
