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
