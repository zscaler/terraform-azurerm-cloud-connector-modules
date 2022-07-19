variable "name_prefix" {
  description = "A prefix to associate to all the module resources"
  default     = "zs"
}

variable "resource_tag" {
  description = "A tag to associate to all the module resources"
  default     = "cloud-connector"
}

variable "resource_group" {
  description = "Main Resource Group Name"
}

variable "location" {
  description = "Azure Region"
}

variable "global_tags" {
  description = "populate custom user provided tags"
}

variable "nsg_count" {
  description = "Default number of network security groups to create"
  default     = 1
}

variable "byo_nsg" {
  default     = false
  type        = bool
  description = "Bring your own network security group for Cloud Connector"
}

variable "byo_mgmt_nsg_names" {
  type        = list(string)
  default     = null
  description = "Management Network Security Group ID for Cloud Connector association"
}

variable "byo_service_nsg_names" {
  type        = list(string)
  default     = null
  description = "Service Network Security Group ID for Cloud Connector association"
}