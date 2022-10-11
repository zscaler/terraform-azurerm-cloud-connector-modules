output "managed_identity_id" {
  description = "User Managed Identity ID"
  value       = data.azurerm_user_assigned_identity.selected.id
}
