################################################################################
# Reference inputs to obtain an existing User Managed Identity Resource 
# to associate to Cloud Connector VM
################################################################################
data "azurerm_user_assigned_identity" "selected" {
  name                = var.cc_vm_managed_identity_name
  resource_group_name = var.cc_vm_managed_identity_rg
}



################################################################################
# Reference inputs to obtain an existing User Managed Identity Resource 
# to associate to to Function App. 

# *Optional* - By default, CCs and Function will use the same Identity
################################################################################
data "azurerm_user_assigned_identity" "function_app_identity_selected" {
  count               = var.vmss_enabled ? 1 : 0
  name                = var.function_app_managed_identity_name
  resource_group_name = var.function_app_managed_identity_rg
}
