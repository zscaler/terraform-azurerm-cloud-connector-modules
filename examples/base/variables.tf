# azure variables

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

variable "server_admin_username" {
  default   = "ubuntu"
  type      = string
}

variable "tls_key_algorithm" {
  default   = "RSA"
  type      = string
}

variable "cc_vm_managed_identity_name" {
  description = "Azure Managed Identity name to attach to the CC VM. E.g zspreview-66117-mi"
  type      = string
}

variable "cc_vm_managed_identity_resource_group" {
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
            var.ccvm_instance_type == "Standard_DS3_v2"
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

variable "vm_count" {
  description = "number of Workload VMs to deploy"
  type    = number
  default = 1
   validation {
          condition     = var.vm_count >= 1 && var.vm_count <= 250
          error_message = "Input vm_count must be a whole number between 1 and 250."
        }
}

variable "cc_count" {
  description = "number of Cloud Connectors to deploy. Validation assumes max for /24 subnet but could be smaller or larger as long as subnet can accommodate"
  type    = number
  default = 1
   validation {
          condition     = var.cc_count == 1
          error_message = "Input cc_count must be equal 1 for this base_cc deployment type."
        }
}

# Validation to determine if Azure Region selected supports availabilty zones if desired
locals {
  az_supported_regions = ["australiaeast","brazilsouth","canadacentral","centralindia","centralus","eastasia","eastus","eastus2","francecentral","germanywestcentral","japaneast","koreacentral","northeurope","norwayeast","southafricanorth","southcentralus","southeastasia","swedencentral","uksouth","westeurope","westus2"]
  zones_supported = (
    contains(local.az_supported_regions, var.arm_location) && var.zones_enabled == true
  )
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