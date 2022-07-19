output "managed_identity_id" {
  value = data.azurerm_user_assigned_identity.selected.id
}