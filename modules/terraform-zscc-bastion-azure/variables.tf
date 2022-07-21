variable "name_prefix" {
  description = "A prefix to associate to all the module resources"
  default     = "zs"
}

variable "resource_tag" {
  description = "A tag to associate to all the module resources"
  default     = "cloud-connector"
}

variable "deployment_tag" {
  description = "A deployment tag to associate to all the module resources"
  default     = "development"
}

variable "resource_group" {
  description = "Main Resource Group Name"
}

variable "public_subnet_id" {
  description = "The id of public subnet where the bastion host has to be attached"
}

variable "server_admin_username" {
  default = "centos"
  type    = string
}

variable "ssh_key" {
  description = "SSH Key for instances"
}

variable "instance_size" {
  description = "The image size"
  default     = "Standard_B1s"
}

variable "instance_image_publisher" {
  description = "The image publisher"
  default     = "OpenLogic"
}

variable "instance_image_offer" {
  description = "The image offer"
  default     = "CentOS"
}

variable "instance_image_sku" {
  description = "The image sku"
  default     = "7.5"
}

variable "instance_image_version" {
  description = "The image version"
  default     = "latest"
}

variable "global_tags" {
  description = "populate custom user provided tags"
}

variable "location" {
  description = "Azure Region"
}

variable "bastion_nsg_source_prefix" {
  description = "user input for locking down SSH access to bastion to a specific IP or CIDR range"
  default     = "*"
}