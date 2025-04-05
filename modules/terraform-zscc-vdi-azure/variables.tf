variable "resource_group_name" {
  description = "Main Resource Group Name"
}

variable "resource_group_location" {
  description = "Azure Region"
}

variable "prefix" {
  description = "A prefix to associate to VDI module resources"
  type        = string
}

variable "admin_username" {
  description = "VDI Admin username for login"
  default     = "ccvdiuser"
}

variable "subnet_id" {
  description = "Subnet ID to associate to VDI Windows Instance"
}

variable "primary_service_ip" {
  description = "Cloud Connector Service Ip to add route to forward traffic from VDI Windows Instance"
}

variable "resource_tag" {
  description = "A tag to associate to VDI module resources"
}

variable "cca_template_url" {
  description = "Create a set of configurations that are applied to the VDI and dictate the VDI's behavior."
}

variable "cca_token" {
  description = "Generated Token for VDI Template URL"
}

variable "workload_count" {
  type        = number
  description = "The number of vdi instances to deploy.  Validation assumes max for /24 subnet but could be smaller or larger as long as subnet can accommodate"
  default     = 1
  validation {
    condition     = var.workload_count >= 1 && var.workload_count <= 250
    error_message = "Input cc_count must be a whole number between 1 and 250."
  }
}
