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

# TF-AZ-10 least-privilege role outputs (null unless create_cc_read_role = true)
output "cc_read_role_definition_id" {
  description = "Resource ID of the least-privilege Custom Role definition, if created."
  value       = var.create_cc_read_role ? azurerm_role_definition.cc_nic_read[0].role_definition_resource_id : null
}

output "cc_read_role_assignment_id" {
  description = "Resource ID of the least-privilege Custom Role assignment, if created."
  value       = var.create_cc_read_role ? azurerm_role_assignment.cc_nic_read[0].id : null
}

# TF-AZ-09 least-privilege role outputs (null unless create_function_app_role = true)
output "function_app_role_definition_id" {
  description = "Resource ID of the least-privilege Function App VMSS ops Custom Role definition, if created."
  value       = var.create_function_app_role ? azurerm_role_definition.function_app_vmss_ops[0].role_definition_resource_id : null
}

output "function_app_role_assignment_id" {
  description = "Resource ID of the least-privilege Function App VMSS ops Custom Role assignment, if created."
  value       = var.create_function_app_role ? azurerm_role_assignment.function_app_vmss_ops[0].id : null
}

output "function_app_kv_secrets_role_assignment_id" {
  description = "Resource ID of the 'Key Vault Secrets User' role assignment for the Function App identity, if created."
  value       = var.create_function_app_role ? azurerm_role_assignment.function_app_kv_secrets[0].id : null
}
