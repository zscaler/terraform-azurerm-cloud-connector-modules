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
# TF-AZ-10 remediation: optional least-privilege Custom Role
#
# When create_cc_read_role = true, Terraform will:
#   1. Create an Azure Custom Role Definition granting ONLY
#      Microsoft.Network/networkInterfaces/read
#   2. Assign it to the CC managed identity at the Cloud Connector
#      Resource Group scope
#
# This replaces the historical guidance of granting the built-in
# `Network Contributor` role at Subscription scope.
#
# Default is false to preserve backwards compatibility: existing users
# who assigned a role out of band are unaffected. Requires the caller
# (Service Principal running Terraform) to have
# Microsoft.Authorization/roleDefinitions/write and
# Microsoft.Authorization/roleAssignments/write at Subscription scope.
################################################################################
variable "create_cc_read_role" {
  type        = bool
  description = "If true, create and assign a least-privilege Custom Role (Microsoft.Network/networkInterfaces/read) to the CC managed identity at the Cloud Connector Resource Group scope. See TF-AZ-10 remediation notes."
  default     = false
}

variable "cc_resource_group_name" {
  type        = string
  description = "Name of the Resource Group where Cloud Connector VMs will be deployed. Required only when create_cc_read_role = true; the created role assignment is scoped to this RG."
  default     = ""
}

variable "cc_read_role_name" {
  type        = string
  description = "Optional custom name for the least-privilege role definition. If empty, defaults to '<cc_vm_managed_identity_name>-nic-read'. Only used when create_cc_read_role = true."
  default     = ""
}
