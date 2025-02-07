variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the workload module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the workload module resources"
  default     = null
}

variable "global_tags" {
  type        = map(string)
  description = "Populate any custom user defined tags from a map"
  default     = {}
}

variable "resource_group_name" {
  type        = string
  description = "Existing Resource Group Name"
  default     = null
}

variable "location" {
  type        = string
  description = "Azure region to create Resource Group for Zscaler Event Grid System Topic (Not required if using an existing resource group via var.resource_group)"
  default     = null
}

variable "subscription_id" {
  type        = string
  description = "(Optional) Azure Subscription ID for Event Grid System Topic source property. If none specified, resource will use caller subscription id"
  default     = null
}

variable "partnerdestination_id" {
  type        = string
  description = "Zscaler registered PartnerDestination ID. example: /subscriptions/<subscriptionId>/resourceGroups/<partnerResourceGroup/providers/Microsoft.EventGrid/partnerDestinations/<partnerDestinationName>"
}
