locals {

  testbedconfig = <<TB

Resource Group: 
${data.azurerm_resource_group.selected.name}


All CC Management IPs:
${join("\n", module.cc-vm.private_ip)}

All CC Primary Service IPs:
${join("\n", module.cc-vm.service_ip)}

LB IP: 
${module.cc-lb.lb_ip}

All NAT GW IPs:
${join("\n", data.azurerm_public_ip.selected.*.ip_address)}

TB
}

output "testbedconfig" {
  value = local.testbedconfig
}

resource "local_file" "testbed" {
  content = local.testbedconfig
  filename = "testbed.txt"
}