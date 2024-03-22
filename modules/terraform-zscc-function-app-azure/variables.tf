variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the CC VM module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the CC VM module resources"
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

variable "managed_identity_id" {
  type        = string
  description = "ID of the User Managed Identity assigned to Cloud Connector VM"
}

variable "zscaler_cc_function_deploy_local_file" {
  type        = bool
  description = "Set to True if you wish to deploy a local file using Zip Deploy method."
  default     = false
}

variable "zscaler_cc_function_public_url" {
  type        = string
  description = "Path to the zscaler_cc_function file."
  default     = ""
}

variable "cc_function_app_settings" {
  type        = map(string)
  description = "App Setting key-value pair environment variables required for Cloud Connector VMSS App Function"
}
