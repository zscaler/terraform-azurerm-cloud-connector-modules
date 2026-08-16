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

# TF-AZ-10 (opt-in): replaces the historical Network Contributor @ Subscription
# scope guidance. Default false preserves backwards compatibility. Requires
# the calling Service Principal to have roleDefinitions/write and
# roleAssignments/write at Subscription scope.
variable "create_cc_read_role" {
  type        = bool
  description = "TF-AZ-10 (opt-in): create and assign a least-privilege Custom Role (networkInterfaces/read only) to the CC managed identity at the CC Resource Group scope."
  default     = false
}

# TF-AZ-09 (opt-in): requires vmss_enabled = true and a distinct
# function_app_managed_identity_name/_rg. Default false preserves backwards
# compatibility. Requires the calling Service Principal to have
# roleDefinitions/write and roleAssignments/write at Subscription scope.
variable "create_function_app_role" {
  type        = bool
  description = "TF-AZ-09 (opt-in): create a least-privilege VMSS-ops Custom Role and assign it, plus 'Key Vault Secrets User', to the Function App identity at the CC Resource Group scope. Requires vmss_enabled = true; Key Vault assignment requires enable_rbac_authorization = true on the vault."
  default     = false
}

# Shared by TF-AZ-09/TF-AZ-10 opt-in roles: RG scope for both assignments.
variable "cc_resource_group_name" {
  type        = string
  description = "Resource Group where CC VMs (and Key Vault) are deployed. Required when create_cc_read_role and/or create_function_app_role = true."
  default     = ""
}

variable "cc_read_role_name" {
  type        = string
  description = "Optional custom name for the least-privilege role definition. If empty, defaults to '<cc_vm_managed_identity_name>-nic-read'. Only used when create_cc_read_role = true."
  default     = ""
}

variable "function_app_role_name" {
  type        = string
  description = "Optional custom name for the Function App VMSS ops role definition. If empty, defaults to '<function_app_managed_identity_name>-vmss-ops'. Only used when create_function_app_role = true."
  default     = ""
}
