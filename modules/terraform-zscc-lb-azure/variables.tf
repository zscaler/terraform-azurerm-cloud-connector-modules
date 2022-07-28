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
  description = "port for Cloud Connector cloud init to enable listener port for HTTP probe from LB"
  default     = 50000
  validation {
    condition = (
      var.http_probe_port == 80 ||
      (var.http_probe_port >= 1024 && var.http_probe_port <= 65535)
    )
    error_message = "Input http_probe_port must be set to a single value of 80 or any number between 1024-65535."
  }
}

variable "load_distribution" {
  type        = string
  description = "Azure LB load distribution method"
  default     = "SourceIP"
  validation {
    condition = (
      var.load_distribution == "SourceIP" ||
      var.load_distribution == "SourceIPProtocol" ||
      var.load_distribution == "Default"
    )
    error_message = "Input load_distribution must be set to either SourceIP, SourceIPProtocol, or Default."
  }
}