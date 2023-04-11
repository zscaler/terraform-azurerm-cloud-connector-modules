locals {

  testbedconfig = <<TB

Resource Group: 
${module.network.resource_group_name}

All CC Management IPs:
${join("\n", module.cc_vm.private_ip)}

All CC Primary Service IPs:
${join("\n", module.cc_vm.service_ip)}

LB IP: 
${module.cc_lb.lb_ip}

All NAT GW IPs:
${join("\n", module.network.public_ip_address)}

Private DNS Resolver:
${try(module.private_dns.private_dns_resolver_name, "")}

Private DNS Forwarding Ruleset:
${try(module.private_dns.private_dns_forwarding_ruleset_name, "")}

Private DNS Outbound Endpoint:
${try(module.private_dns.private_dns_outbound_endpoint_name, "")}

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
