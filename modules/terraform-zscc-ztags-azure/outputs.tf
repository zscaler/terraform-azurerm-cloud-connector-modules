output "ztags_resource_group_name" {
  description = "Event Grid System Topic Resource Group Name"
  value       = var.resource_group_name != null ? data.azurerm_resource_group.existing_zs_tags_rg[0].name : azurerm_resource_group.zs_tags_rg[0].name
}

output "ztags_resource_group_id" {
  description = "Event Grid System Topic Resource Group Name"
  value       = var.resource_group_name != null ? data.azurerm_resource_group.existing_zs_tags_rg[0].id : azurerm_resource_group.zs_tags_rg[0].id
}

output "ztags_event_grid_system_topic_id" {
  description = "Event Grid System Topic ID for Zscaler Tagging Service"
  value       = azapi_resource.zs_system_topic.output.id
}

output "ztags_event_grid_system_topic_name" {
  description = "Event Grid System Topic Name for Zscaler Tagging Service"
  value       = azapi_resource.zs_system_topic.name
}
