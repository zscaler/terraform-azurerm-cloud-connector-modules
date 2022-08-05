################################################################################
# Reference inputs to obtain an existing User Managed Identity Resource 
# to associate to Cloud Connector VM
################################################################################
data "azurerm_user_assigned_identity" "selected" {
  name                = var.cc_vm_managed_identity_name
  resource_group_name = var.cc_vm_managed_identity_rg
}