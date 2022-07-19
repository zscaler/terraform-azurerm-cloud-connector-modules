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

variable "subnet_id" {
  description = "Subnet ID for LB Frontend IP placement"
}


variable "http_probe_port" {
  description = "port for Cloud Connector cloud init to enable listener port for HTTP probe from LB"
  default = 0
  validation {
          condition     = (
            var.http_probe_port == 0 ||
            var.http_probe_port == 80 ||
          ( var.http_probe_port >= 1024 && var.http_probe_port <= 65535 )
        )
          error_message = "Input http_probe_port must be set to a single value of 80 or any number between 1024-65535."
      }
}

variable "location" {
  description = "Azure Region"
}

variable "load_distribution" {
  type = string
  description = "Azure LB load distribution method"
  default = "SourceIP"
   validation {
          condition     = ( 
            var.load_distribution == "SourceIP"  ||
            var.load_distribution == "SourceIPProtocol" ||
            var.load_distribution == "Default"
          )
          error_message = "Input load_distribution must be set to either SourceIP, SourceIPProtocol, or Default."
      }
}
variable "global_tags" {
  description = "populate custom user provided tags"
}

