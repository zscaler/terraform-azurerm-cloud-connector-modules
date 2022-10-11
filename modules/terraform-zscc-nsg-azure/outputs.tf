output "mgmt_nsg_id" {
  description = "Management Network Security Group ID"
  value       = data.azurerm_network_security_group.mgt_nsg_selected.*.id
}

output "service_nsg_id" {
  description = "Service Network Security Group ID"
  value       = data.azurerm_network_security_group.service_nsg_selected.*.id
}
