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
