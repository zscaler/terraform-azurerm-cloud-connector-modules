output "resource_group_name" {
  description = "Azure Resource Group Name"
  value       = var.byo_rg ? data.azurerm_resource_group.rg_selected[0].name : azurerm_resource_group.rg[0].name
}

output "cc_subnet_ids" {
  description = "Cloud Connector Subnet ID"
  value       = data.azurerm_subnet.cc_subnet_selected[*].id
}

output "public_ip_address" {
  description = "Azure Public IP Address"
  value       = var.byo_pips ? data.azurerm_public_ip.pip_selected[*].ip_address : azurerm_public_ip.pip[*].ip_address
}

output "bastion_subnet_ids" {
  description = "Bastion Host Subnet ID"
  value       = azurerm_subnet.bastion_subnet[*].id
}

output "workload_subnet_ids" {
  description = "Workloads Subnet ID"
  value       = azurerm_subnet.workload_subnet[*].id
}

output "virtual_network_id" {
  description = "Azure Virtual Network ID"
  value       = var.byo_vnet ? data.azurerm_virtual_network.vnet_selected[0].id : azurerm_virtual_network.vnet[0].id
}

output "virtual_network_vwan_connection_id" {
  description = "ID of connection from Azure Virtual Network to Virtual WAN"
  value       = var.vwan_hub_id != null && var.vwan_hub_id != "" ? (var.vnet_connection_name != null && var.vnet_connection_name != "" ? data.azurerm_virtual_hub_connection.vnet_to_vwan_selected[0].id : azurerm_virtual_hub_connection.vnet_to_vwan[0].id) : ""
}

output "private_dns_subnet_id" {
  description = "Private DNS Outbound Endpoint Subnet ID"
  value       = var.zpa_enabled ? azurerm_subnet.private_dns_subnet[0].id : ""
}
