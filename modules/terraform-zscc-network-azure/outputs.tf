output "resource_group_name" {
  description = "Azure Resource Group Name"
  value       = data.azurerm_resource_group.rg_selected.name
}

output "cc_subnet_ids" {
  description = "Cloud Connector Subnet ID"
  value       = data.azurerm_subnet.cc_subnet_selected.*.id
}

output "public_ip_address" {
  description = "Azure Public IP Address"
  value       = data.azurerm_public_ip.pip_selected.*.ip_address
}

output "bastion_subnet_ids" {
  description = "Bastion Host Subnet ID"
  value       = azurerm_subnet.bastion_subnet.*.id
}

output "workload_subnet_ids" {
  description = "Workloads Subnet ID"
  value       = azurerm_subnet.workload_subnet.*.id
}
