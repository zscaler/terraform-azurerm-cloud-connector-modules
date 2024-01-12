variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the lb module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the lb module resources"
  default     = null
}

variable "global_tags" {
  type        = map(string)
  description = "Populate any custom user defined tags from a map"
  default     = {}
}

variable "resource_group" {
  type        = string
  description = "Main Resource Group Name"
}

variable "location" {
  type        = string
  description = "Cloud Connector Azure Region"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for LB Frontend IP placement"
}

variable "http_probe_port" {
  type        = number
  description = "Port number for Cloud Connector cloud init to enable listener port for HTTP probe from Azure LB"
  default     = 50000
  validation {
    condition = (
      tonumber(var.http_probe_port) == 80 ||
      (tonumber(var.http_probe_port) >= 1024 && tonumber(var.http_probe_port) <= 65535)
    )
    error_message = "Input http_probe_port must be set to a single value of 80 or any number between 1024-65535."
  }
}

variable "load_distribution" {
  type        = string
  description = "Azure LB load distribution method"
  default     = "Default"
  validation {
    condition = (
      var.load_distribution == "SourceIP" ||
      var.load_distribution == "SourceIPProtocol" ||
      var.load_distribution == "Default"
    )
    error_message = "Input load_distribution must be set to either SourceIP, SourceIPProtocol, or Default."
  }
}

# Validation to determine if Azure Region selected supports availabilty zones if desired
locals {
  az_supported_regions = ["australiaeast", "Australia East", "brazilsouth", "Brazil South", "canadacentral", "Canada Central", "centralindia", "Central India", "centralus", "Central US", "chinanorth3", "China North 3", "ChinaNorth3", "eastasia", "East Asia", "eastus", "East US", "eastus2", "East US 2", "francecentral", "France Central", "germanywestcentral", "Germany West Central", "japaneast", "Japan East", "koreacentral", "Korea Central", "northeurope", "North Europe", "norwayeast", "Norway East", "southafricanorth", "South Africa North", "southcentralus", "South Central US", "southeastasia", "Southeast Asia", "swedencentral", "Sweden Central", "switzerlandnorth", "Switzerland North", "uaenorth", "UAE North", "uksouth", "UK South", "westeurope", "West Europe", "westus2", "West US 2", "westus3", "West US 3"]
  zones_supported = (
    contains(local.az_supported_regions, var.location) && var.zones_enabled == true
  )
  frontend_zone_specific = length(var.zones) == 1 ? var.zones : ["1", "2", "3"] ##If user specifies a single zone number for a zones supported region set just that zone. Otherwise, set all 3 zones (zone-redundant)
}

variable "zones_enabled" {
  type        = bool
  description = "Determine whether to provision Cloud Connector VMs explicitly in defined zones (if supported by the Azure region provided in the location variable). If left false, Azure will automatically choose a zone and module will create an availability set resource instead for VM fault tolerance"
  default     = false
}

variable "zones" {
  type        = list(string)
  description = "Specify which availability zone(s) to deploy VM resources in if zones_enabled variable is set to true"
  default     = ["1"]
  validation {
    condition = (
      !contains([for zones in var.zones : contains(["1", "2", "3"], zones)], false)
    )
    error_message = "Input zones variable must be a number 1-3."
  }
}

variable "health_check_interval" {
  type        = number
  description = "The interval, in seconds, for how frequently to probe the endpoint for health status. Typically, the interval is slightly less than half the allocated timeout period (in seconds) which allows two full probes before taking the instance out of rotation. The default value is 15, the minimum value is 5"
  default     = 15
  validation {
    condition = (
      var.health_check_interval > 4
    )
    error_message = "Input health_check_interval must be a number 5 or greater."
  }
}

variable "probe_threshold" {
  type        = number
  description = "The number of consecutive successful or failed probes in order to allow or deny traffic from being delivered to this endpoint. After failing the number of consecutive probes equal to this value, the endpoint will be taken out of rotation and require the same number of successful consecutive probes to be placed back in rotation."
  default     = 2
}

variable "number_of_probes" {
  type        = number
  description = "The number of probes where if no response, will result in stopping further traffic from being delivered to the endpoint. This values allows endpoints to be taken out of rotation faster or slower than the typical times used in Azure"
  default     = 1
}
