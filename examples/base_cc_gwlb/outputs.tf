locals {
  testbedconfig = <<-TB
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

  Login Instructions & Resource Attributes

  CLOUD CONNECTOR Details/Commands:
  SSH to CLOUD CONNECTOR
  %{for k, v in local.cc_map~}
  ssh -F ssh_config ccvm-${k}
  %{endfor~}  

  All Cloud Connector Management IPs:
  %{for k, v in local.cc_map~}
  ccvm-${k} = ${v}
  %{endfor~}

  All Cloud Connector Service IPs:
  ${join("\n", module.cc_vm.service_ip)}


  BASTION Jump Host Details/Commands:
  1) Copy the SSH key to BASTION home directory
  scp -F ssh_config ${var.name_prefix}-key-${random_string.suffix.result}.pem bastion:~/.

  2) SSH to BASTION
  ssh -F ssh_config bastion

  BASTION Public IP: 
  ${module.bastion.public_ip}

  Resource Group: 
  ${module.network.resource_group_name}

  All NAT GW IPs:
  ${join("\n", module.network.public_ip_address)}

  Gateway Load Balancer Frontend IP (private - GWLB provider):
  ${module.cc_gwlb.gwlb_ip}

  Gateway Load Balancer Frontend IP Config ID (set this on your consumer PLB to activate chaining):
  ${module.cc_gwlb.gwlb_frontend_ip_config_id}

  %{if length(module.cc_public_lb) > 0~}
  Consumer Public Load Balancer IP (internet ingress entry point, auto-chained to GWLB):
  ${module.cc_public_lb[0].lb_ip}
  %{else~}
  No consumer PLB was created by Terraform.
  To activate GWLB ingress inspection, go to Azure Portal -> your existing Public LB
  -> Frontend IP configurations -> Edit -> Gateway Load Balancer -> paste the ID above -> Save.
  %{endif~}

  Workload VM IPs (behind GWLB/CC inspection path):
  ${join("\n  ", module.workload.private_ip)}
  TB
}

locals {
  cc_map = {
    for index, ip in module.cc_vm.private_ip :
    index => ip
  }
  ssh_config_contents = <<-SSH_CONFIG
    Host bastion
      HostName ${module.bastion.public_ip}
      User ${module.bastion.admin_username}
      IdentityFile ${var.name_prefix}-key-${random_string.suffix.result}.pem
    
    %{for k, v in local.cc_map~}
    Host ccvm-${k}
      HostName ${v}
      User zsroot
      IdentityFile ${var.name_prefix}-key-${random_string.suffix.result}.pem
      StrictHostKeyChecking no
      ProxyJump bastion        
      ProxyCommand ssh bastion -W %h:%p
    %{endfor~}
  SSH_CONFIG
}

output "testbedconfig" {
  description = "Azure Testbed results"
  value       = local.testbedconfig
}


resource "local_file" "ssh_config" {
  content  = local.ssh_config_contents
  filename = "../ssh_config"
}

resource "local_file" "testbed" {
  content  = local.testbedconfig
  filename = "../testbed.txt"
}
