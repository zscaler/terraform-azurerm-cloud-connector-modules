
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


WORKLOAD Details/Commands:
SSH to WORKLOAD
%{for k, v in local.workload_map~}
ssh -F ssh_config workload-${k}
%{endfor~}  

WORKLOAD IPs:
%{for k, v in local.workload_map~}
workload-${k} = ${v}
%{endfor~}  


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


VDI Public IP:
${join("\n", module.cc_vdi[0].public_ip_address)}

VDI Username:
${local.admin_username}

VDI Password:
${nonsensitive(local.admin_password)}

TB
}
locals {
  workload_map = {
    for index, ip in module.workload.private_ip :
    index => ip
  }
  cc_map = {
    for index, ip in module.cc_vm.private_ip :
    index => ip
  }
  ssh_config_contents = <<SSH_CONFIG
    Host bastion
      HostName ${module.bastion.public_ip}
      User ${module.bastion.admin_username}
      IdentityFile ${var.name_prefix}-key-${random_string.suffix.result}.pem

    %{for k, v in local.workload_map~}
Host workload-${k}
      HostName ${v}
      User ${module.workload.admin_username}
      IdentityFile ${var.name_prefix}-key-${random_string.suffix.result}.pem
      StrictHostKeyChecking no
      ProxyJump bastion
      ProxyCommand ssh bastion -W %h:%p
    %{endfor~}    
    
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
