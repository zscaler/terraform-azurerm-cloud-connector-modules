# azure variables

variable "arm_location" {
  description = "The Azure location."
  default     = "westus2"
}

variable "name_prefix" {
  description = "The name prefix for all your resources"
  default     = "zs"
  type        = string
}

variable "network_address_space" {
  description = "VNET CIDR"
  default     = "10.1.0.0/16"
}

variable "cc_subnets" {
  description = "Cloud Connector Subnets"
  default     = null
  type        = list(string)
}

variable "environment" {
  description = "Environment"
  default     = "Development"
}

variable "tls_key_algorithm" {
  default = "RSA"
  type    = string
}

variable "workload_count" {
  description = "number of Workload VMs to deploy"
  type        = number
  default     = 1
  validation {
    condition     = var.workload_count >= 1 && var.workload_count <= 250
    error_message = "Input workload_count must be a whole number between 1 and 250."
  }
}

# Validation to determine if Azure Region selected supports availabilty zones if desired
locals {
  az_supported_regions = ["australiaeast", "brazilsouth", "canadacentral", "centralindia", "centralus", "eastasia", "eastus", "eastus2", "francecentral", "germanywestcentral", "japaneast", "koreacentral", "northeurope", "norwayeast", "southafricanorth", "southcentralus", "southeastasia", "swedencentral", "uksouth", "westeurope", "westus2"]
  zones_supported = (
    contains(local.az_supported_regions, var.arm_location) && var.zones_enabled == true
  )
}

variable "zones_enabled" {
  type        = bool
  default     = false
  description = "Azure Region"
}

variable "zones" {
  type        = list(string)
  default     = ["1"]
  description = "Azure Region"
  validation {
    condition = (
      !contains([for zones in var.zones : contains(["1", "2", "3"], zones)], false)
    )
    error_message = "Input zones variable must be a number 1-3."
  }
}

variable "owner_tag" {
  description = "populate custom owner tag attribute"
  type        = string
  default     = "zscc-admin"
}