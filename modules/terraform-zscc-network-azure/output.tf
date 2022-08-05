output "resource_group_name" {
  value = data.azurerm_resource_group.rg-selected.name
}

output "cc_subnet_ids" {
  value = data.azurerm_subnet.cc-subnet-selected.*.id
}

output "public_ip_address" {
  value = data.azurerm_public_ip.pip-selected.*.ip_address
}

output "bastion_subnet_ids" {
  value = azurerm_subnet.bastion-subnet.*.id
}

output "workload_subnet_ids" {
  value = azurerm_subnet.workload-subnet.*.id
}

