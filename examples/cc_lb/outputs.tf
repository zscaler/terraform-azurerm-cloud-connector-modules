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

All Cloud Connector Management IPs:
${join("\n", module.cc_vm.private_ip)}

All Cloud Connector Service IPs:
${join("\n", module.cc_vm.service_ip)}

Load Balancer Frontend IP: 
${module.cc_lb.lb_ip}

All NAT GW IPs:
${join("\n", module.network.public_ip_address)}

Private DNS Resolver:
${try(module.private_dns.private_dns_resolver_name, "N/A")}

Private DNS Forwarding Ruleset:
${try(module.private_dns.private_dns_forwarding_ruleset_name, "N/A")}

Private DNS Outbound Endpoint:
${try(module.private_dns.private_dns_outbound_endpoint_name, "N/A")}

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
