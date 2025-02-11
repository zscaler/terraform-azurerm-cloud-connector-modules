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
1) Copy the SSH key to BASTION home directory
scp -F ssh_config ${var.name_prefix}-key-${random_string.suffix.result}.pem bastion

2) SSH to BASTION
ssh -F ssh_config bastion

3) SSH to WORKLOAD
%{for k, v in local.workload_map~}
ssh -F ssh_config workload-${k}
%{endfor~}  

All Workload IPs:
%{for k, v in local.workload_map~}
workload-${k} = ${v}
%{endfor~}  

Resource Group: 
${module.network.resource_group_name}

Load Balancer Frontend IP:  
${module.cc_lb.lb_ip}

VMSS Names:
${join("\n", module.cc_vmss.vmss_names)}

VMSS IDs:
${join("\n", module.cc_vmss.vmss_ids)}

Function App ID:
${module.cc_functionapp.function_app_id}

Function App Outbound IPs:
${join("\n", module.cc_functionapp.function_app_outbound_ip_address_list)}

All NAT GW IPs:
${join("\n", module.network.public_ip_address)}

Bastion Public IP: 
${module.bastion.public_ip}

Private DNS Resolver:
${module.private_dns.private_dns_resolver_name}

Private DNS Forwarding Ruleset:
${module.private_dns.private_dns_forwarding_ruleset_name}

Private DNS Outbound Endpoint:
${module.private_dns.private_dns_outbound_endpoint_name}

TB

  testbedconfig_manual_sync_failed = <<TB
**IMPORTANT (ONLY APPLICABLE FOR INITIAL CREATE OF FUNCTION APP)**
Based on the recorded output, the manual sync to start your Azure Function App failed. To perform this manual sync perform one of the following steps:
  1. Navigate to the Azure Function App ${module.cc_functionapp.function_app_id} on the Azure Portal. The loading of the Function App page triggers the manual sync and will start your Function App.
  2. Attempt to rerun the manual_sync.sh script manually using the following command (path to file is based on root of the repo):
      ../../modules/terraform-zscc-function-app-azure/manual_sync.sh ${module.cc_functionapp.subscription_id} ${module.network.resource_group_name} ${module.cc_functionapp.function_app_name}
**IMPORTANT (ONLY APPLICABLE FOR INITIAL CREATE OF FUNCTION APP)**

TB
}
locals {
  workload_map = {
    for index, ip in module.workload.private_ip :
    index => ip
  }
  ssh_config_contents = <<SSH_CONFIG
    Host bastion
      HostName ${module.bastion.public_ip}
      User centos
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
  SSH_CONFIG
}

resource "local_file" "ssh_config" {
  content  = local.ssh_config_contents
  filename = "../ssh_config"
}

output "testbedconfig" {
  description = "Azure Testbed results"
  value       = module.cc_functionapp.manual_sync_exit_status != "1" ? local.testbedconfig : format("%s%s", local.testbedconfig, local.testbedconfig_manual_sync_failed)
}

resource "local_file" "testbed" {
  content  = module.cc_functionapp.manual_sync_exit_status != "1" ? local.testbedconfig : format("%s%s", local.testbedconfig, local.testbedconfig_manual_sync_failed)
  filename = "../testbed.txt"
}
