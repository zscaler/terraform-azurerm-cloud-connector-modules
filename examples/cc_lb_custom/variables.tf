# azure variables

variable "env_subscription_id" {
  type        = string
  description = "Azure Subscription ID where resources are to be deployed in"
  sensitive   = true
}

variable "arm_location" {
  description = "The Azure location."
  default     = "westus2"
}

variable "name_prefix" {
  description = "The name prefix for all your resources"
  default     = "zs"
  type        = string
}

variable "network_address_space" {
  description = "VNET CIDR"
  default     = "10.1.0.0/16"
}

variable "cc_subnets" {
  description = "Cloud Connector Subnets"
  default     = null
  type        = list(string)
}

variable "environment" {
  description = "Environment"
  default     = "Development"
}

variable "tls_key_algorithm" {
  default   = "RSA"
  type      = string
}

variable "managed_identity_subscription_id" {
  default     = null
  type        = string
  description = "Azure Subscription ID where the User Managed Identity resource exists"
  sensitive   = true
}

variable "cc_vm_managed_identity_name" {
  description = "Azure Managed Identity name to attach to the CC VM. E.g zspreview-66117-mi"
  type      = string
}

variable "cc_vm_managed_identity_rg" {
  description = "Resource Group of the Azure Managed Identity name to attach to the CC VM. E.g. edgeconnector_rg_1"
  type      = string
}

variable "cc_vm_prov_url" {
  description = "Zscaler Cloud Connector Provisioning URL"
  type        = string
}

variable "azure_vault_url" {
  description = "Azure Vault URL"
  type        = string
}

variable "ccvm_image_publisher" {
  description = "Azure Marketplace Cloud Connector Image Publisher"
  default     = "zscaler1579058425289"
}

variable "ccvm_image_offer" {
  description = "Azure Marketplace Cloud Connector Image Offer"
  default     = "zia_cloud_connector"
}

variable "ccvm_image_sku" {
  description = "Azure Marketplace Cloud Connector Image SKU"
  default     = "zs_ser_gen1_cc_01"
}

variable "ccvm_image_version" {
  description = "Azure Marketplace Cloud Connector Image Version"
  default     = "latest"
}

variable "ccvm_instance_type" {
  description = "Cloud Connector Image size"
  default     = "Standard_D2s_v3"
  validation {
          condition     = ( 
            var.ccvm_instance_type == "Standard_D2s_v3"  ||
            var.ccvm_instance_type == "Standard_DS3_v2"  ||
            var.ccvm_instance_type == "Standard_D8s_v3"  ||
            var.ccvm_instance_type == "Standard_D16s_v3" ||
            var.ccvm_instance_type == "Standard_DS5_v2"
          )
          error_message = "Input ccvm_instance_type must be set to an approved vm size."
      }
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

variable "cc_count" {
  description = "number of Cloud Connectors to deploy. Validation assumes max for /24 subnet but could be smaller or larger as long as subnet can accommodate"
  type    = number
  default = 2
   validation {
          condition     = var.cc_count >= 1 && var.cc_count <= 250
          error_message = "Input cc_count must be a whole number between 1 and 250."
        }
}

variable "byo_rg" {
  default     = false
  type        = bool
  description = "Bring your own Azure Resource Group"
}

variable "byo_rg_name" {
  default     = ""
  type        = string
  description = "User provided existing Azure Resource Group"
}

variable "byo_vnet" {
  default     = false
  type        = bool
  description = "Bring your own Azure VNET for Cloud Connector"
}

variable "byo_vnet_name" {
  default     = ""
  type        = string
  description = "User provided existing Azure Resource Group"
}

variable "byo_subnets" {
  default     = false
  type        = bool
  description = "Bring your own Azure subnets for Cloud Connector"
}

variable "byo_subnet_names" {
  default     = null
  type        = list(string)
  description = "User provided existing Cloud Connector subnets"
}

variable "byo_vnet_subnets_rg_name" {
  default     = ""
  type        = string
  description = "User provided existing Azure VNET Resource Group"
}

variable "byo_pips" {
  default     = false
  type        = bool
  description = "Bring your own Azure Public IP addresses for the NAT GW"
}

variable "byo_pip_names" {
  default     = null
  type        = list(string)
  description = "User provided Azure Public IP address names for the NAT GW"
}

variable "byo_pip_rg" {
  default     = ""
  type        = string
  description = "User provided Azure Public IP address resource group for the NAT GW"
}

variable "byo_nat_gws" {
  default     = false
  type        = bool
  description = "Bring your own Azure NAT Gateways"
}

variable "byo_nat_gw_names" {
  default     = null
  type        = list(string)
  description = "User provided existing NAT Gateway names"
}

variable "byo_nat_gw_rg" {
  default     = ""
  type        = string
  description = "User provided existing NAT Gateway Resource Group"
}

variable "existing_nat_gw_pip_association" {
  default     = false
  type        = bool
  description = "Bring your own Azure Public IP address already associated to an existing bring your own Azure NAT Gateway"
}

variable "existing_nat_gw_subnet_association" {
  default     = false
  type        = bool
  description = "Bring your own Azure NAT Gateway already associated to an existing bring your own Cloud Connector subnet"
}

variable "zones_enabled" {
  type        = bool
  default     =  false  
  description = "Azure Region"
}

variable "zones" {
  type        = list(string)
  default     = ["1"]
  description = "Azure Region"
  validation {
          condition     = (
            !contains([for zones in var.zones: contains( ["1", "2", "3"], zones)], false)
          )
          error_message = "Input zones variable must be a number 1-3."
      }
}

variable "owner_tag" {
  description = "populate custom owner tag attribute"
  type = string
  default = "zscc-admin"
}


# Validation to determine if Azure Region selected supports availabilty zones if desired
locals {
  az_supported_regions = ["australiaeast","brazilsouth","canadacentral","centralindia","centralus","eastasia","eastus","eastus2","francecentral","germanywestcentral","japaneast","koreacentral","northeurope","norwayeast","southafricanorth","southcentralus","southeastasia","swedencentral","uksouth","westeurope","westus2"]
  zones_supported = (
    contains(local.az_supported_regions, var.arm_location) && var.zones_enabled == true
  )
  pip_zones = (
    contains(local.az_supported_regions, var.arm_location) ? "Zone-Redundant" : "No-Zone"
  )
}

variable "cc_instance_size" {
  default = "small"
   validation {
          condition     = ( 
            var.cc_instance_size == "small"  ||
            var.cc_instance_size == "medium" ||
            var.cc_instance_size == "large"
          )
          error_message = "Input cc_instance_size must be set to an approved cc instance type."
      }
}

# Validation to determine if the selected Azure VM type and CC VM size is compatible 
locals {
  small_cc_instance  = ["Standard_D2s_v3","Standard_DS3_v2","Standard_D8s_v3","Standard_D16s_v3","Standard_DS5_v2"]
  medium_cc_instance = ["Standard_DS3_v2","Standard_D8s_v3","Standard_D16s_v3","Standard_DS5_v2"]
  large_cc_instance  = ["Standard_D16s_v3","Standard_DS5_v2"]
  
  valid_cc_create = (
contains(local.small_cc_instance, var.ccvm_instance_type) && var.cc_instance_size == "small"   ||
contains(local.medium_cc_instance, var.ccvm_instance_type) && var.cc_instance_size == "medium" ||
contains(local.large_cc_instance, var.ccvm_instance_type) && var.cc_instance_size == "large"
 )
}

variable "reuse_nsg" {
  description = "Specifies whether the NSG module should create 1:1 network security groups per instance or 1 network security group for all instances"
  default     = "false"
  type        = bool
}

variable "byo_nsg" {
  default     = false
  type        = bool
  description = "Bring your own Network Security Group for Cloud Connector"
}

variable "byo_nsg_rg" {
  default     = ""
  type        = string
  description = "User provided existing NSG Resource Group"
}

variable "byo_mgmt_nsg_names" {
  type = list(string)
  default = null
  description = "Management Network Security Group ID for Cloud Connector association"
}

variable "byo_service_nsg_names" {
  type = list(string)
  default = null
  description = "Service Network Security Group ID for Cloud Connector association"
}

variable "accelerated_networking_enabled" {
  type        = bool
  default     =  false  
  description = "Enable/Disable accelerated networking support on all Cloud Connector service interfaces"
}

variable "load_distribution" {
  type = string
  description = "Azure LB load distribution method"
  default = "SourceIP"
   validation {
          condition     = ( 
            var.load_distribution == "SourceIP"  || ## 2 tuple hash
            var.load_distribution == "SourceIPProtocol" || ## 3 tuple hash
            var.load_distribution == "Default"  # 5 tuple hash
          )
          error_message = "Input load_distribution must be set to either SourceIP, SourceIPProtocol, or Default."
      }
}