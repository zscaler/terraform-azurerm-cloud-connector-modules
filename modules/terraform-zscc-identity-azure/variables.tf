variable "cc_vm_managed_identity_name" {
  description = "Azure Managed Identity name to attach to the CC VM. E.g zspreview-66117-mi"
  type        = string
}

variable "cc_vm_managed_identity_rg" {
  description = "Resource Group of the Azure Managed Identity name to attach to the CC VM. E.g. edgeconnector_rg_1"
  type        = string
}