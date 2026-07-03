output "mgmt_nsg_id" {
  description = "Management Network Security Group ID"
  value       = var.byo_nsg ? data.azurerm_network_security_group.mgt_nsg_selected[*].id : azurerm_network_security_group.cc_mgmt_nsg[*].id
}

output "service_nsg_id" {
  description = "Service Network Security Group ID"
  value       = var.byo_nsg ? data.azurerm_network_security_group.service_nsg_selected[*].id : azurerm_network_security_group.cc_service_nsg[*].id
}

################################################################################
# Output the NSG ID for the service interface in GWLB deployments
################################################################################
output "service_gwlb_nsg_id" {
  description = "Network Security Group ID for the service interface in Gateway Load Balancer (GWLB) deployments"
  value       = var.gwlb_enabled ? azurerm_network_security_group.cc_service_gwlb_nsg[0].id : null
}
