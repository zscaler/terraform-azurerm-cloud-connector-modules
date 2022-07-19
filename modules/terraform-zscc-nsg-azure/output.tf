output "mgmt_nsg_id" {
  value = data.azurerm_network_security_group.mgt-nsg-selected.*.id
}

output "service_nsg_id" {
  value = data.azurerm_network_security_group.service-nsg-selected.*.id
}