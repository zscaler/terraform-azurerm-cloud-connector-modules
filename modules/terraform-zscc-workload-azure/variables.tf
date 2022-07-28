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

variable "subnet_id" {
  type        = string
  description = "The id of subnet where the workload host has to be attached"
}

variable "server_admin_username" {
  type        = string
  description = "Username configured for the workload root/admin account"
  default     = "centos"
}

variable "ssh_key" {
  type        = string
  description = "SSH Key for instances"
}

variable "instance_size" {
  type        = string
  description = "The Azure image type/size"
  default     = "Standard_B1s"
}

variable "instance_image_publisher" {
  type        = string
  description = "The workload CentOS image publisher"
  default     = "OpenLogic"
}

variable "instance_image_offer" {
  type        = string
  description = "The workload CentOS image offer"
  default     = "CentOS"
}

variable "instance_image_sku" {
  type        = string
  description = "The workload CentOS image sku"
  default     = "7.5"
}

variable "instance_image_version" {
  type        = string
  description = "The workload CentOS image version"
  default     = "latest"
}

variable "workload_count" {
  type        = number
  description = "The number of Workload VMs to deploy"
  default     = 1
  validation {
    condition     = var.workload_count >= 1 && var.workload_count <= 250
    error_message = "Input workload_count must be a whole number between 1 and 250."
  }
}

# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  type        = list(string)
  description = "The DNS servers configured for workload VMs."
  default     = []
}