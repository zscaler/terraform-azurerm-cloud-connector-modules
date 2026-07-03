variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the NSG module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the NSG module resources"
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

variable "support_access_enabled" {
  type        = bool
  description = "If Network Security Group is being configured, enable a specific outbound rule for Cloud Connector to be able to establish connectivity for Zscaler support access. Default is true"
  default     = true
}

variable "zssupport_server" {
  type        = string
  description = "destination IP address of Zscaler Support access server. IP resolution of remotesupport.<zscaler_customer_cloud>.net"
  default     = "199.168.148.101" #for commercial clouds
}

variable "public_lb_deployed" {
  type        = bool
  description = "Check if any Public Load Balancer deployed or not"
  default     = false
}

variable "gwlb_enabled" {
  type        = bool
  description = "Create a dedicated NSG for Gateway Load Balancer VXLAN traffic. Only set to true for GWLB deployment types"
  default     = false
}

variable "vxlan_internal_port" {
  type        = number
  description = "VXLAN internal UDP port configured on the GWLB backend pool tunnel interface. Used to scope the GWLB NSG inbound rule to only the configured port range. Must match the value passed to the terraform-zscc-gwlb-azure module."
  default     = 10800
}

variable "vxlan_external_port" {
  type        = number
  description = "VXLAN external UDP port configured on the GWLB backend pool tunnel interface. Used to scope the GWLB NSG inbound rule to only the configured port range. Must match the value passed to the terraform-zscc-gwlb-azure module."
  default     = 10801
}
