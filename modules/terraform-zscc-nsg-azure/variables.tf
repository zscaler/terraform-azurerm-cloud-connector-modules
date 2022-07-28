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

variable "resource_group" {
  type        = string
  description = "Main Resource Group Name"
}

variable "location" {
  type        = string
  description = "Cloud Connector Azure Region"
}

variable "nsg_count" {
  type        = number
  description = "Default number of network security groups to create"
  default     = 1
}

variable "byo_nsg" {
  type        = bool
  description = "Bring your own network security group for Cloud Connector"
  default     = false
}

variable "byo_mgmt_nsg_names" {
  type        = list(string)
  description = "Management Network Security Group ID for Cloud Connector association"
  default     = null
}

variable "byo_service_nsg_names" {
  type        = list(string)
  description = "Service Network Security Group ID for Cloud Connector association"
  default     = null
}