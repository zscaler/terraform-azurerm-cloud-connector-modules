output "managed_identity_id" {
  description = "User Managed Identity ID"
  value       = data.azurerm_user_assigned_identity.selected.id
}

output "managed_identity_client_id" {
  description = "The Client ID of the User Assigned Identity"
  value       = data.azurerm_user_assigned_identity.selected.client_id
}

output "managed_identity_principal_id" {
  description = "The Object(Principal) ID of the User Assigned Identity"
  value       = data.azurerm_user_assigned_identity.selected.principal_id
}

#Function app Managed Identity outputs
output "function_app_managed_identity_id" {
  description = "User Managed Identity ID dedicated for VMSS Function App"
  value       = var.vmss_enabled ? data.azurerm_user_assigned_identity.function_app_identity_selected[0].id : null
}

output "function_app_managed_identity_client_id" {
  description = "The Client ID of the User Assigned Identity dedicated for VMSS Function App"
  value       = var.vmss_enabled ? data.azurerm_user_assigned_identity.function_app_identity_selected[0].client_id : null
}

output "function_app_managed_identity_principal_id" {
  description = "The Object(Principal) ID of the User Assigned Identity dedicated for VMSS Function App"
  value       = var.vmss_enabled ? data.azurerm_user_assigned_identity.function_app_identity_selected[0].principal_id : null
}
