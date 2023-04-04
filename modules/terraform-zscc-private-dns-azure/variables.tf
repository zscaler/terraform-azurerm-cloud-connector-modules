variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the Private DNS module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the Private DNS module resources"
  default     = null
}

variable "global_tags" {
  type        = map(string)
  description = "Populate any custom user defined tags from a map"
  default     = {}
}

variable "resource_group" {
  type        = string
  description = "Specifies the name of the Resource Group where the Private DNS Resolver should exist"
}

variable "location" {
  type        = string
  description = "Specifies the Azure Region where the Private DNS Resolver should exist"
}

variable "vnet_id" {
  type        = string
  description = "The ID of the Virtual Network that is linked to the Private DNS Resolver"
}

variable "private_dns_subnet_id" {
  type        = string
  description = "The ID of the Subnet that is linked to the Private DNS Resolver Outbound Endpoint"
}

variable "target_address" {
  type        = list(string)
  description = "Azure DNS queries will be conditionally forwarded to these target IP addresses. Default are a pair of Zscaler Global VIP addresses"
  default     = ["185.46.212.88", "185.46.212.89"]
}

variable "domain_names" {
  type        = map(any)
  description = "Domain names fqdn/wildcard to have Azure Private DNS redirect DNS requests to Cloud Connector"
}
