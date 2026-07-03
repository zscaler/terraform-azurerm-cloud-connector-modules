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


Resource Group:
${module.network.resource_group_name}

Cloud Connector VMSS Names:
${join("\n", module.cc_vmss.vmss_names)}

VMSS IDs:
${join("\n", module.cc_vmss.vmss_ids)}

Gateway Load Balancer Frontend IP (private):
${module.cc_gwlb.gwlb_ip}

Gateway Load Balancer Frontend IP Config ID:
${module.cc_gwlb.gwlb_frontend_ip_config_id}

%{if length(module.cc_public_lb) > 0~}
Consumer Public Load Balancer IP (auto-created and chained to GWLB):
${module.cc_public_lb[0].lb_ip}
%{else~}
No consumer PLB was created by Terraform.
To activate GWLB ingress inspection, go to Azure Portal → your existing Public LB
→ Frontend IP configurations → Edit → Gateway Load Balancer → paste the ID above → Save.
%{endif~}

All NAT GW IPs:
${join("\n", module.network.public_ip_address)}

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
