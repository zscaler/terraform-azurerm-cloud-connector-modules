################################################################################
# Reference inputs to obtain an existing User Managed Identity Resource 
# to associate to Cloud Connector VM
################################################################################
data "azurerm_user_assigned_identity" "selected" {
  provider            = azurerm.managed_identity_sub
  name                = var.cc_vm_managed_identity_name
  resource_group_name = var.cc_vm_managed_identity_rg
}



################################################################################
# Reference inputs to obtain an existing User Managed Identity Resource
# to associate to the Function App autoscaler.
#
# TF-AZ-09: must be a distinct identity from the CC VM's, so a compromised
# CC VM can't inherit the autoscaler's power to delete sibling CCs / read
# Key Vault secrets. Precondition below enforces this.
################################################################################
data "azurerm_user_assigned_identity" "function_app_identity_selected" {
  count               = var.vmss_enabled ? 1 : 0
  provider            = azurerm.managed_identity_sub
  name                = var.function_app_managed_identity_name
  resource_group_name = var.function_app_managed_identity_rg

  lifecycle {
    precondition {
      condition     = var.function_app_managed_identity_name != "" && var.function_app_managed_identity_rg != ""
      error_message = "TF-AZ-09: function_app_managed_identity_name/rg must be set to a distinct identity from cc_vm_managed_identity_name/rg when vmss_enabled = true."
    }
    precondition {
      condition     = var.function_app_managed_identity_name != var.cc_vm_managed_identity_name || var.function_app_managed_identity_rg != var.cc_vm_managed_identity_rg
      error_message = "TF-AZ-09: function_app_managed_identity_name/rg must differ from cc_vm_managed_identity_name/rg."
    }
  }
}

################################################################################
# TF-AZ-09 (opt-in): least-privilege Custom Role + Key Vault access for the
# Function App autoscaler identity. Guarded by create_function_app_role.
################################################################################
data "azurerm_subscription" "fa_current" {
  count = var.create_function_app_role ? 1 : 0
}

data "azurerm_resource_group" "fa_cc_rg" {
  count = var.create_function_app_role ? 1 : 0
  name  = var.cc_resource_group_name

  lifecycle {
    precondition {
      condition     = var.vmss_enabled
      error_message = "TF-AZ-09: create_function_app_role requires vmss_enabled = true."
    }
    precondition {
      condition     = var.cc_resource_group_name != ""
      error_message = "TF-AZ-09: create_function_app_role requires cc_resource_group_name to be set."
    }
  }
}

resource "azurerm_role_definition" "function_app_vmss_ops" {
  count       = var.create_function_app_role ? 1 : 0
  name        = coalesce(var.function_app_role_name, "${var.function_app_managed_identity_name}-vmss-ops")
  scope       = data.azurerm_subscription.fa_current[0].id
  description = "Least-privilege VMSS ops role for CC Function App autoscaler (TF-AZ-09)."

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachineScaleSets/read",
      "Microsoft.Compute/virtualMachineScaleSets/write",
      "Microsoft.Compute/virtualMachineScaleSets/delete/action",
      "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/read",
      "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/write",
      "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/delete",
    ]
    data_actions     = []
    not_actions      = []
    not_data_actions = []
  }

  assignable_scopes = [data.azurerm_resource_group.fa_cc_rg[0].id]
}

resource "azurerm_role_assignment" "function_app_vmss_ops" {
  count              = var.create_function_app_role ? 1 : 0
  scope              = data.azurerm_resource_group.fa_cc_rg[0].id
  role_definition_id = azurerm_role_definition.function_app_vmss_ops[0].role_definition_resource_id
  principal_id       = data.azurerm_user_assigned_identity.function_app_identity_selected[0].principal_id
  description        = "TF-AZ-09 VMSS ops assignment for CC Function App autoscaler."
}

# Built-in 'Key Vault Secrets User' role, scoped to the CC RG, so the
# autoscaler can read Zscaler provisioning secrets.
#
# CAVEAT: RBAC assignment only takes effect if the target Key Vault has
# enable_rbac_authorization = true. Legacy Access Policy vaults need an
# explicit access policy entry instead.
resource "azurerm_role_assignment" "function_app_kv_secrets" {
  count                = var.create_function_app_role ? 1 : 0
  scope                = data.azurerm_resource_group.fa_cc_rg[0].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_user_assigned_identity.function_app_identity_selected[0].principal_id
  description          = "TF-AZ-09 Key Vault secret-read assignment for CC Function App autoscaler."
}

################################################################################
# TF-AZ-10 (opt-in): least-privilege Custom Role for the CC managed identity.
# Replaces the historical Network Contributor @ Subscription scope guidance.
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
  description = "Least-privilege role for CC managed identity: networkInterfaces/read only (TF-AZ-10)."

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
  description        = "TF-AZ-10 least-privilege assignment for CC managed identity."
}
