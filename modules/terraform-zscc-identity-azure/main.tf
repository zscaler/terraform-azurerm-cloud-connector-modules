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

################################################################################
# TF-AZ-10 remediation: optional least-privilege Custom Role for the CC
# managed identity.
#
# When create_cc_read_role = true, a Custom Role granting only
# Microsoft.Network/networkInterfaces/read is created at Subscription scope
# and assigned to the CC managed identity at the Cloud Connector Resource
# Group scope. This is the recommended replacement for the historical
# Network Contributor at Subscription scope guidance.
################################################################################
data "azurerm_subscription" "current" {
  count = var.create_cc_read_role ? 1 : 0
}

data "azurerm_resource_group" "cc_rg" {
  count = var.create_cc_read_role ? 1 : 0
  name  = var.cc_resource_group_name
}

resource "azurerm_role_definition" "cc_nic_read" {
  count       = var.create_cc_read_role ? 1 : 0
  name        = coalesce(var.cc_read_role_name, "${var.cc_vm_managed_identity_name}-nic-read")
  scope       = data.azurerm_subscription.current[0].id
  description = "Least-privilege role for Zscaler Cloud Connector managed identity. Grants only Microsoft.Network/networkInterfaces/read. Ref: TF-AZ-10."

  permissions {
    actions          = ["Microsoft.Network/networkInterfaces/read"]
    data_actions     = []
    not_actions      = []
    not_data_actions = []
  }

  assignable_scopes = [data.azurerm_resource_group.cc_rg[0].id]
}

resource "azurerm_role_assignment" "cc_nic_read" {
  count              = var.create_cc_read_role ? 1 : 0
  scope              = data.azurerm_resource_group.cc_rg[0].id
  role_definition_id = azurerm_role_definition.cc_nic_read[0].role_definition_resource_id
  principal_id       = data.azurerm_user_assigned_identity.selected.principal_id
  description        = "TF-AZ-10 least-privilege assignment for Zscaler Cloud Connector managed identity."
}
