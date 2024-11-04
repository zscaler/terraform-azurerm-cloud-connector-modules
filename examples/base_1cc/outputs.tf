
locals {
  admin_password = (
    try(
      module.cc_vdi[0].admin_password,
      (sensitive("NA"))
    )
  )
  admin_username = (
    try(
      module.cc_vdi[0].admin_username,
      "NA"
    )
  )
  public_ip_address = (
    try(
      module.cc_vdi[0].public_ip_address,
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
${local.public_ip_address}

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