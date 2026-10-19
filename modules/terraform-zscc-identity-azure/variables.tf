variable "cc_vm_managed_identity_name" {
  type        = string
  description = "Azure Managed Identity name to attach to the CC VM. E.g zspreview-66117-mi"
}

variable "cc_vm_managed_identity_rg" {
  type        = string
  description = "Resource Group of the Azure Managed Identity name to attach to the CC VM. E.g. edgeconnector_rg_1"
}

variable "function_app_managed_identity_name" {
  type        = string
  description = "Azure Managed Identity name to attach to the Function App. E.g zspreview-66117-mi"
  default     = ""
}

variable "function_app_managed_identity_rg" {
  type        = string
  description = "Resource Group of the Azure Managed Identity name to attach to the Function App. E.g. edgeconnector_rg_1"
  default     = ""
}

variable "vmss_enabled" {
  type        = bool
  description = "Default is false non non-vmss deployments. If true, module will do a data lookup for an additional managed identity resource for Function App in the same subscription"
  default     = false
}

################################################################################
# TF-AZ-09 remediation: optional least-privilege Custom Role for the CC
# Function App autoscaler managed identity.
#
# When create_function_app_role = true, Terraform will:
#   1. Create a Custom Role granting only the VMSS Compute operations the
#      Function App autoscaler actually needs (read/write VMSS +
#      per-instance read/write/delete).
#   2. Assign that custom role at the CC Resource Group scope.
#   3. Additionally assign the built-in 'Key Vault Secrets User' role at
#      the CC Resource Group scope so the autoscaler can read Zscaler
#      provisioning secrets.
#
# Default false preserves backwards compatibility: existing users who
# assigned roles out of band are unaffected. Requires vmss_enabled = true
# and both function_app_managed_identity_name/_rg to be non-empty
# (enforced by the module preconditions).
#
# Requires the caller (Service Principal running Terraform) to have
# Microsoft.Authorization/roleDefinitions/write and
# Microsoft.Authorization/roleAssignments/write at Subscription scope.
################################################################################
variable "create_function_app_role" {
  type        = bool
  description = "If true, create a least-privilege Custom Role for the Function App autoscaler (VMSS Compute ops) and assign it — plus 'Key Vault Secrets User' — to the Function App managed identity at the CC Resource Group scope. Requires vmss_enabled = true. See TF-AZ-09 remediation notes."
  default     = false
}

variable "cc_resource_group_name" {
  type        = string
  description = "Name of the Resource Group where Cloud Connector VMs and their Key Vault will be deployed. Required when create_function_app_role = true (used as the assignable_scope + role_assignment scope) and/or when create_cc_read_role = true."
  default     = ""
}

variable "function_app_role_name" {
  type        = string
  description = "Optional custom name for the Function App VMSS ops role definition. If empty, defaults to '<function_app_managed_identity_name>-vmss-ops'. Only used when create_function_app_role = true."
  default     = ""
}
