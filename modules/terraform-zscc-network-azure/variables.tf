variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the Bastion Host module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the Bastion Host module resources"
  default     = null
}

variable "global_tags" {
  type        = map(string)
  description = "Populate any custom user defined tags from a map"
  default     = {}
}

variable "location" {
  type        = string
  description = "Cloud Connector Azure Region"
}

variable "network_address_space" {
  type        = string
  description = "VNET CIDR / address prefix"
  default     = "10.1.0.0/16"
}

variable "cc_subnets" {
  type        = list(string)
  description = "Cloud Connector Subnets to create in VNet. This is only required if you want to override the default subnets that this code creates"
  default     = null
}

# Validation to determine if Azure Region selected supports availabilty zones if desired
locals {
  az_supported_regions = ["australiaeast", "brazilsouth", "canadacentral", "centralindia", "centralus", "eastasia", "eastus", "francecentral", "germanywestcentral", "japaneast", "koreacentral", "northeurope", "norwayeast", "southafricanorth", "southcentralus", "southeastasia", "swedencentral", "uksouth", "westeurope", "westus2"]
  zones_supported = (
    contains(local.az_supported_regions, var.location) && var.zones_enabled == true
  )
  pip_zones = contains(local.az_supported_regions, var.location) ? "Zone-Redundant" : "No-Zone"
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

variable "workloads_enabled" {
  type        = bool
  description = "Configure Workload Subnets, Route Tables, and associations if set to true"
  default     = false
}

variable "base_only" {
  type        = bool
  description = "Default is falase. Only applicable for base deployment type resulting in workload and bastion hosts, but no Cloud Connector resources. Setting this to true will point workload route able to Internet"
  default     = false
}

variable "lb_enabled" {
  type        = bool
  description = "Default true. Configure Workload Route Table to default route next hop to the CC Load Balancer IP passed from var.lb_frontend_ip. If false, default route next hop directly to the CC Service IP passed from var.cc_service_ip"
  default     = true
}

variable "lb_frontend_ip" {
  type = string
  description = "IP address of Cloud Connector Load Balancer frontend. Used for greenfield deployment types like base_cc_lb so workload subnets automatically default route to this IP as next hop"
  default = null
}

variable "cc_service_ip" {
  type = list(string)
  description = "IP address of Cloud Connector Service IP. Used for non-ha greenfield deployment types like base_cc so workload subnets automatically default route to this IP as next hop"
  default = [""]
}

# BYO (Bring-your-own) variables list

variable "byo_rg" {
  type        = bool
  description = "Bring your own Azure Resource Group. If false, a new resource group will be created automatically"
  default     = false
}

variable "byo_rg_name" {
  type        = string
  description = "User provided existing Azure Resource Group name. This must be populated if byo_rg variable is true"
  default     = ""
}

variable "byo_vnet" {
  type        = bool
  description = "Bring your own Azure VNet for Cloud Connector. If false, a new VNet will be created automatically"
  default     = false
}

variable "byo_vnet_name" {
  type        = string
  description = "User provided existing Azure VNet name. This must be populated if byo_vnet variable is true"
  default     = ""
}

variable "byo_subnets" {
  type        = bool
  description = "Bring your own Azure subnets for Cloud Connector. If false, new subnet(s) will be created automatically. Default 1 subnet for Cloud Connector if 1 or no zones specified. Otherwise, number of subnes created will equal number of Cloud Connector zones"
  default     = false
}

variable "byo_subnet_names" {
  type        = list(string)
  description = "User provided existing Azure subnet name(s). This must be populated if byo_subnets variable is true"
  default     = null
}

variable "byo_vnet_subnets_rg_name" {
  type        = string
  description = "User provided existing Azure VNET Resource Group. This must be populated if either byo_vnet or byo_subnets variables are true"
  default     = ""
}

variable "byo_pips" {
  type        = bool
  description = "Bring your own Azure Public IP addresses for the NAT Gateway(s) association"
  default     = false
}

variable "byo_pip_names" {
  type        = list(string)
  description = "User provided Azure Public IP address resource names to be associated to NAT Gateway(s)"
  default     = null
}

variable "byo_pip_rg" {
  type        = string
  description = "User provided Azure Public IP address resource group name. This must be populated if byo_pip_names variable is true"
  default     = ""
}

variable "byo_nat_gws" {
  type        = bool
  description = "Bring your own Azure NAT Gateways"
  default     = false
}

variable "byo_nat_gw_names" {
  type        = list(string)
  description = "User provided existing NAT Gateway resource names. This must be populated if byo_nat_gws variable is true"
  default     = null
}

variable "byo_nat_gw_rg" {
  type        = string
  description = "User provided existing NAT Gateway Resource Group. This must be populated if byo_nat_gws variable is true"
  default     = ""
}

variable "existing_nat_gw_pip_association" {
  type        = bool
  description = "Set this to true only if both byo_pips and byo_nat_gws variables are true. This implies that there are already NAT Gateway resources with Public IP Addresses associated so we do not attempt any new associations"
  default     = false
}

variable "existing_nat_gw_subnet_association" {
  type        = bool
  description = "Set this to true only if both byo_nat_gws and byo_subnets variables are true. this implies that there are already NAT Gateway resources associated to subnets where Cloud Connectors are being deployed to"
  default     = false
}
