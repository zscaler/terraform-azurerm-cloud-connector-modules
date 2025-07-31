variable "arm_location" {
  type        = string
  description = "The Azure Region where resources are to be deployed"
  default     = "westus2"
}

variable "name_prefix" {
  type        = string
  description = "The name prefix for all your resources"
  default     = "zstags"
  validation {
    condition     = length(var.name_prefix) <= 12
    error_message = "Variable name_prefix must be 12 or less characters."
  }
}

variable "environment" {
  type        = string
  description = "Customer defined environment tag. ie: Dev, QA, Prod, etc."
  default     = "Development"
}

variable "owner_tag" {
  type        = string
  description = "Customer defined owner tag value. ie: Org, Dept, username, etc."
  default     = "zscc-admin"
}

variable "partnerdestination_id" {
  type        = string
  description = "Zscaler registered PartnerDestination ID. example: /subscriptions/<subscriptionId>/resourceGroups/<partnerResourceGroup/providers/Microsoft.EventGrid/partnerDestinations/<partnerDestinationName>"
}

variable "existing_ztags_rg_name" {
  type        = string
  description = "Existing Resource Group name to create Z-Tag resources"
  default     = null
}

variable "subscription_id" {
  type        = string
  description = "(Optional) Azure Subscription ID for Event Grid System Topic source property. If none specified, resource will use caller subscription id"
  default     = null
}
