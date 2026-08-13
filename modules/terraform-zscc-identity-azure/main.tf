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
# TF-AZ-09 remediation: this identity MUST be a distinct User-Assigned
# Managed Identity from the one attached to the Cloud Connector VMs. The
# Function App requires VMSS Compute write/delete and Key Vault secret-read
# permissions that Cloud Connector VMs do not need; reusing a single
# identity across both components means a compromised CC VM inherits the
# Function App's power to delete sibling CCs and read all vault secrets.
#
# The precondition below fails plan when vmss_enabled = true and no
# separate Function App identity has been supplied.
################################################################################
data "azurerm_user_assigned_identity" "function_app_identity_selected" {
  count               = var.vmss_enabled ? 1 : 0
  provider            = azurerm.managed_identity_sub
  name                = var.function_app_managed_identity_name
  resource_group_name = var.function_app_managed_identity_rg

  lifecycle {
    precondition {
      condition     = var.function_app_managed_identity_name != "" && var.function_app_managed_identity_rg != ""
      error_message = "TF-AZ-09: A separate managed identity is required for the Function App when vmss_enabled = true. Set function_app_managed_identity_name and function_app_managed_identity_rg to a DISTINCT identity from cc_vm_managed_identity_name/rg. Reusing the CC VM identity grants a compromised CC instance the ability to delete sibling CCs and read all Function App secrets. See README.md prerequisites and TF-AZ-09 remediation notes."
    }
    precondition {
      condition     = var.function_app_managed_identity_name != var.cc_vm_managed_identity_name || var.function_app_managed_identity_rg != var.cc_vm_managed_identity_rg
      error_message = "TF-AZ-09: function_app_managed_identity_name/rg must reference a DIFFERENT managed identity than cc_vm_managed_identity_name/rg. Both currently point to the same identity, which recreates the shared-identity privilege-escalation exposure this control is designed to prevent."
    }
  }
}

################################################################################
# TF-AZ-09 remediation (opt-in): least-privilege Custom Role + assignments
# for the Function App autoscaler managed identity.
#
# Guarded by create_function_app_role. When true, provisions:
#   * A Custom Role Definition (VMSS Compute read/write + per-instance
#     read/write/delete) scoped to the CC Resource Group.
#   * A role assignment binding that custom role to the Function App
#     managed identity at the CC Resource Group scope.
#   * A role assignment binding the built-in "Key Vault Secrets User"
#     role to the Function App managed identity at the CC Resource
#     Group scope (autoscaler needs to read Zscaler provisioning secrets).
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
      error_message = "TF-AZ-09: create_function_app_role requires vmss_enabled = true. The Function App identity only exists in VMSS deployments."
    }
    precondition {
      condition     = var.cc_resource_group_name != ""
      error_message = "TF-AZ-09: create_function_app_role requires cc_resource_group_name to be set. This is the Resource Group scope for both the custom role's assignable_scopes and both role assignments."
    }
  }
}

resource "azurerm_role_definition" "function_app_vmss_ops" {
  count       = var.create_function_app_role ? 1 : 0
  name        = coalesce(var.function_app_role_name, "${var.function_app_managed_identity_name}-vmss-ops")
  scope       = data.azurerm_subscription.fa_current[0].id
  description = "Least-privilege role for Zscaler CC Function App autoscaler. Grants only VMSS Compute read/write + per-instance read/write/delete on the CC Resource Group. Ref: TF-AZ-09."

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
  description        = "TF-AZ-09 least-privilege VMSS ops assignment for Zscaler CC Function App autoscaler."
}

# Built-in role: 'Key Vault Secrets User' — read secret contents (get/list secret versions).
# Assigned at CC RG scope so the autoscaler can read Zscaler provisioning secrets from
# any Key Vault in the CC RG. If tighter scoping to a specific vault is required,
# customers can create the assignment out of band and leave create_function_app_role = false.
resource "azurerm_role_assignment" "function_app_kv_secrets" {
  count                = var.create_function_app_role ? 1 : 0
  scope                = data.azurerm_resource_group.fa_cc_rg[0].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_user_assigned_identity.function_app_identity_selected[0].principal_id
  description          = "TF-AZ-09 Key Vault secret-read assignment for Zscaler CC Function App autoscaler."
}
