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

variable "resource_group" {
  type        = string
  description = "Main Resource Group Name"
}

variable "location" {
  type        = string
  description = "Cloud Connector Azure Region"
}

variable "public_subnet_id" {
  type        = string
  description = "The id of public subnet where the bastion host has to be attached"
}

variable "server_admin_username" {
  type        = string
  description = "Username configured for the Bastion Host root/admin account"
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
  description = "The Bastion Host CentOS image publisher"
  default     = "OpenLogic"
}

variable "instance_image_offer" {
  type        = string
  description = "The Bastion Host CentOS image offer"
  default     = "CentOS"
}

variable "instance_image_sku" {
  type        = string
  description = "The Bastion Host CentOS image sku"
  default     = "7.5"
}

variable "instance_image_version" {
  type        = string
  description = "The Bastion Host CentOS image version"
  default     = "latest"
}

variable "bastion_nsg_source_prefix" {
  type        = string
  description = "user input for locking down SSH access to bastion to a specific IP or CIDR range"
  default     = "*"
}
