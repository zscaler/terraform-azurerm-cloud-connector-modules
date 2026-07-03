variable "env_subscription_id" {
  type        = string
  description = "Azure Subscription ID where resources are to be deployed in"
  sensitive   = true
}

variable "arm_location" {
  type        = string
  description = "The Azure Region where resources are to be deployed"
  default     = "westus2"
}

variable "name_prefix" {
  type        = string
  description = "The name prefix for all your resources"
  default     = "zscc"
  validation {
    condition     = length(var.name_prefix) <= 12
    error_message = "Variable name_prefix must be 12 or less characters."
  }
}

variable "network_address_space" {
  type        = string
  description = "VNET CIDR / address prefix. Only used when byo_vnet = false"
  default     = "10.1.0.0/16"
}

variable "cc_subnets" {
  type        = list(string)
  description = "Cloud Connector Subnets to create in VNet. Only used when byo_subnets = false"
  default     = null
}

variable "environment" {
  type        = string
  description = "Customer defined environment tag. ie: Dev, QA, Prod, etc."
  default     = "Development"
}

variable "owner_tag" {
  type        = string
  description = "Customer defined owner tag value. ie: Org, Dept, username, etc."
  default     = "zscc-admin"
}

variable "tls_key_algorithm" {
  type        = string
  description = "algorithm for tls_private_key resource"
  default     = "RSA"
}

variable "managed_identity_subscription_id" {
  type        = string
  description = "Azure Subscription ID where the User Managed Identity resource exists. Only required if this Subscription ID is different than env_subscription_id"
  default     = null
  sensitive   = true
}

variable "cc_vm_managed_identity_name" {
  type        = string
  description = "Azure Managed Identity name to attach to the CC VM. E.g zspreview-66117-mi"
}

variable "cc_vm_managed_identity_rg" {
  type        = string
  description = "Resource Group of the Azure Managed Identity name to attach to the CC VM. E.g. edgeconnector_rg_1"
}

variable "cc_vm_prov_url" {
  type        = string
  description = "Zscaler Cloud Connector Provisioning URL"
}

variable "azure_vault_url" {
  type        = string
  description = "Azure Vault URL"
}

variable "ccvm_instance_type" {
  type        = string
  description = "Cloud Connector Image size"
  default     = "Standard_D2s_v3"
  validation {
    condition = (
      var.ccvm_instance_type == "Standard_D2s_v3" ||
      var.ccvm_instance_type == "Standard_DS2_v2" ||
      var.ccvm_instance_type == "Standard_DS3_v2"
    )
    error_message = "Input ccvm_instance_type must be set to an approved vm size."
  }
}

variable "ccvm_image_publisher" {
  type        = string
  description = "Azure Marketplace Cloud Connector Image Publisher"
  default     = "zscaler1579058425289"
}

variable "ccvm_image_offer" {
  type        = string
  description = "Azure Marketplace Cloud Connector Image Offer"
  default     = "zia_cloud_connector"
}

variable "ccvm_image_sku" {
  type        = string
  description = "Azure Marketplace Cloud Connector Image SKU"
  default     = "zs_ser_gen1_cc_01"
}

variable "ccvm_image_version" {
  type        = string
  description = "Azure Marketplace Cloud Connector Image Version"
  default     = "latest"
}

variable "ccvm_source_image_id" {
  type        = string
  description = "Custom Cloud Connector Source Image ID. Set this value to the path of a local subscription Microsoft.Compute image to override the Cloud Connector deployment instead of using the marketplace publisher"
  default     = null
}

variable "http_probe_port" {
  type        = number
  description = "Port number for Cloud Connector cloud init to enable listener port for HTTP probe from Azure LB"
  default     = 50000
  validation {
    condition = (
      tonumber(var.http_probe_port) == 80 ||
      (tonumber(var.http_probe_port) >= 1024 && tonumber(var.http_probe_port) <= 65535)
    )
    error_message = "Input http_probe_port must be set to a single value of 80 or any number between 1024-65535."
  }
}

variable "cc_count" {
  type        = number
  description = "The number of Cloud Connectors to deploy. Validation assumes max for /24 subnet but could be smaller or larger as long as subnet can accommodate"
  default     = 2
  validation {
    condition     = var.cc_count >= 1 && var.cc_count <= 250
    error_message = "Input cc_count must be a whole number between 1 and 250."
  }
}

variable "zones_enabled" {
  type        = bool
  description = "Determine whether to provision Cloud Connector VMs explicitly in defined zones (if supported by the Azure region provided in the location variable). If left false, Azure will automatically choose a zone and module will create an availability set resource instead for VM fault tolerance"
  default     = false
}

variable "zones" {
  type        = list(string)
  description = "Specify which availability zone(s) to deploy VM resources in if zones_enabled variable is set to true"
  default     = ["1"]
  validation {
    condition = (
      !contains([for zones in var.zones : contains(["1", "2", "3"], zones)], false)
    )
    error_message = "Input zones variable must be a number 1-3."
  }
}

variable "reuse_nsg" {
  type        = bool
  description = "Specifies whether the NSG module should create 1:1 network security groups per instance or 1 network security group for all instances"
  default     = false
}

variable "accelerated_networking_enabled" {
  type        = bool
  description = "Enable/Disable accelerated networking support on all Cloud Connector service interfaces"
  default     = true
}

variable "load_distribution" {
  type        = string
  description = "Azure LB load distribution method"
  default     = "Default"
  validation {
    condition = (
      var.load_distribution == "SourceIP" ||
      var.load_distribution == "SourceIPProtocol" ||
      var.load_distribution == "Default"
    )
    error_message = "Input load_distribution must be set to either SourceIP, SourceIPProtocol, or Default."
  }
}

variable "health_check_interval" {
  type        = number
  description = "The interval, in seconds, for how frequently to probe the endpoint for health status. Typically, the interval is slightly less than half the allocated timeout period (in seconds) which allows two full probes before taking the instance out of rotation. The default value is 15, the minimum value is 5"
  default     = 15
  validation {
    condition = (
      var.health_check_interval > 4
    )
    error_message = "Input health_check_interval must be a number 5 or greater."
  }
}

variable "probe_threshold" {
  type        = number
  description = "The number of consecutive successful or failed probes in order to allow or deny traffic from being delivered to this endpoint. After failing the number of consecutive probes equal to this value, the endpoint will be taken out of rotation and require the same number of successful consecutive probes to be placed back in rotation."
  default     = 2
}

variable "number_of_probes" {
  type        = number
  description = "The number of probes where if no response, will result in stopping further traffic from being delivered to the endpoint. This values allows endpoints to be taken out of rotation faster or slower than the typical times used in Azure"
  default     = 1
}

variable "encryption_at_host_enabled" {
  type        = bool
  description = "User input for enabling or disabling host encryption"
  default     = true
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

################################################################################
# BYO (Bring-your-own) variables — set these when deploying into an existing VNet
################################################################################
variable "byo_rg" {
  type        = bool
  description = "Bring your own Azure Resource Group. If false, a new resource group will be created"
  default     = false
}

variable "byo_rg_name" {
  type        = string
  description = "User provided existing Azure Resource Group name. This must be populated if byo_rg is true"
  default     = ""
}

variable "byo_vnet" {
  type        = bool
  description = "Bring your own Azure VNet for Cloud Connector. If false, a new VNet will be created"
  default     = false
}

variable "byo_vnet_name" {
  type        = string
  description = "User provided existing Azure VNet name. This must be populated if byo_vnet is true"
  default     = ""
}

variable "byo_subnets" {
  type        = bool
  description = "Bring your own Azure subnets for Cloud Connector. If false, new subnets will be created"
  default     = false
}

variable "byo_subnet_names" {
  type        = list(string)
  description = "User provided existing Azure subnet name(s). This must be populated if byo_subnets is true"
  default     = [""]
}

variable "byo_vnet_subnets_rg_name" {
  type        = string
  description = "User provided existing Azure Resource Group name where the VNet and subnets exist. This must be populated if byo_vnet or byo_subnets is true"
  default     = ""
}

variable "byo_pips" {
  type        = bool
  description = "Bring your own Azure Public IP addresses for the NAT Gateway(s) associated with Cloud Connector subnets. If false, new Public IP(s) will be created"
  default     = false
}

variable "byo_pip_names" {
  type        = list(string)
  description = "User provided existing Azure Public IP name(s). This must be populated if byo_pips is true"
  default     = [""]
}

variable "byo_pip_rg" {
  type        = string
  description = "User provided existing Azure Resource Group name where the Public IP(s) exist. This must be populated if byo_pips is true"
  default     = ""
}

variable "byo_nat_gws" {
  type        = bool
  description = "Bring your own Azure NAT Gateways. If false, new NAT Gateways will be created"
  default     = false
}

variable "byo_nat_gw_names" {
  type        = list(string)
  description = "User provided existing Azure NAT Gateway name(s). This must be populated if byo_nat_gws is true"
  default     = [""]
}

variable "byo_nat_gw_rg" {
  type        = string
  description = "User provided existing Azure Resource Group name where the NAT Gateway(s) exist. This must be populated if byo_nat_gws is true"
  default     = ""
}

variable "existing_nat_gw_pip_association" {
  type        = bool
  description = "Set this to true only if both byo_pips and byo_nat_gws are true. This implies that the NAT Gateway Public IP association already exists and does not need to be created"
  default     = false
}

variable "existing_nat_gw_subnet_association" {
  type        = bool
  description = "Set this to true only if both byo_subnets and byo_nat_gws are true. This implies that the NAT Gateway Subnet association already exists and does not need to be created"
  default     = false
}

variable "byo_nsg" {
  type        = bool
  description = "Bring your own Network Security Groups for Cloud Connector"
  default     = false
}

variable "byo_nsg_rg" {
  type        = string
  description = "User provided existing NSG Resource Group name. This must be populated if byo_nsg is true"
  default     = ""
}

variable "byo_mgmt_nsg_names" {
  type        = list(string)
  description = "Management Network Security Group names for Cloud Connector association. This must be populated if byo_nsg is true"
  default     = [""]
}

variable "byo_service_nsg_names" {
  type        = list(string)
  description = "Service Network Security Group names for Cloud Connector association. This must be populated if byo_nsg is true"
  default     = [""]
}
