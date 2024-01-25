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

variable "fault_domain_count" {
  type        = number
  description = "Number of fault domains to have VMs deployed across"
  default     = 1
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

#### module by default pushes the same single subnet ID for both mgmt_subnet_id and service_subnet_id, so they are effectively the same variable
#### leaving each as unique values should customer choose to deploy mgmt and service as individual subnets for additional isolation
variable "mgmt_subnet_id" {
  type        = string
  description = "Cloud Connector management subnet id. "
}

variable "service_subnet_id" {
  type        = string
  description = "Cloud Connector service subnet id"
}

variable "cc_username" {
  type        = string
  description = "Default Cloud Connector admin/root username"
  default     = "zsroot"
}

variable "ssh_key" {
  type        = string
  description = "SSH Key for instances"
}

variable "ccvm_instance_type" {
  type        = string
  description = "Cloud Connector Image size"
  default     = "Standard_D2s_v3"
  validation {
    condition = (
      var.ccvm_instance_type == "Standard_D2s_v3" ||
      var.ccvm_instance_type == "Standard_DS3_v2" ||
      var.ccvm_instance_type == "Standard_D8s_v3" ||
      var.ccvm_instance_type == "Standard_D16s_v3" ||
      var.ccvm_instance_type == "Standard_DS5_v2"
    )
    error_message = "Input ccvm_instance_type must be set to an approved vm size."
  }
}

variable "user_data" {
  type        = string
  description = "Cloud Init data"
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

variable "backend_address_pool" {
  type        = string
  description = "Azure LB Backend Address Pool ID for NIC association"
  default     = null
}

# Validation to determine if Azure Region selected supports availabilty zones if desired
locals {
  az_supported_regions = ["australiaeast", "Australia East", "brazilsouth", "Brazil South", "canadacentral", "Canada Central", "centralindia", "Central India", "centralus", "Central US", "eastasia", "East Asia", "eastus", "East US", "francecentral", "France Central", "germanywestcentral", "Germany West Central", "japaneast", "Japan East", "koreacentral", "Korea Central", "northeurope", "North Europe", "norwayeast", "Norway East", "southafricanorth", "South Africa North", "southcentralus", "South Central US", "southeastasia", "Southeast Asia", "swedencentral", "Sweden Central", "uksouth", "UK South", "westeurope", "West Europe", "westus2", "West US 2", "westus3", "West US 3"]
  zones_supported = (
    contains(local.az_supported_regions, var.location) && var.zones_enabled == true
  )
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

variable "managed_identity_id" {
  type        = string
  description = "ID of the User Managed Identity assigned to Cloud Connector VM"
}

variable "mgmt_nsg_id" {
  type        = string
  description = "Cloud Connector management interface nsg id"
}

variable "service_nsg_id" {
  type        = string
  description = "Cloud Connector service interface nsg id"
}

variable "accelerated_networking_enabled" {
  type        = bool
  description = "Enable/Disable accelerated networking support on all Cloud Connector service interfaces"
  default     = true
}

# Validation to determine if Azure Region selected supports 3 Fault Domain or just 2.
# This validation is only relevant if zones_enabled is set to false.
locals {
  max_fd_supported_regions = ["eastus", "East US", "eastus2", "East US 2", "westus", "West US", "centralus", "Central US", "northcentralus", "North Central US", "southcentralus", "South Central US", "canadacentral", "Canada Central", "northeurope", "North Europe", "westeurope", "West Europe"]
  max_fd_supported = (
    contains(local.max_fd_supported_regions, var.location) && var.zones_enabled == false
  )
}
variable "encryption_at_host_enabled" {
  type        = bool
  description = "User input for enabling or disabling host encryption"
  default     = true
}

variable "vmss_desired_ccs" {
  type        = number
  description = "Desired number of CCs in vmss."
  default     = 2
}

variable "vmss_min_ccs" {
  type        = number
  description = "Minimum number of CCs in vmss."
  default     = 2
}

variable "vmss_max_ccs" {
  type        = number
  description = "Maximum number of CCs in vmss."
  default     = 16
}

variable "scale_out_evaluation_period" {
  type        = string
  description = "Amount of time the average of scaling metric is evaluated over."
  default     = "PT5M"
}

variable "scale_out_threshold" {
  type        = number
  description = "Metric threshold for determining scale out."
  default     = 70
}

variable "scale_out_count" {
  type        = string
  description = "Number of CCs to bring up on scale out event."
  default     = "1"
}

variable "scale_out_cooldown" {
  type        = string
  description = "Amount of time after scale out before scale out is evaluated again."
  default     = "PT15M"
}

variable "scale_in_evaluation_period" {
  type        = string
  description = "Amount of time the average of scaling metric is evaluated over."
  default     = "PT5M"
}

variable "scale_in_threshold" {
  type        = number
  description = "Metric threshold for determining scale in."
  default     = 30
}

variable "scale_in_count" {
  type        = string
  description = "Number of CCs to bring up on scale in event."
  default     = "1"
}

variable "scale_in_cooldown" {
  type        = string
  description = "Amount of time after scale in before scale in is evaluated again."
  default     = "PT15M"
}

variable "susbcription_id" {
  type        = string
  description = "Subscription ID."
}

variable "managed_identity_client_id" {
  type        = string
  description = "Managed Identity Client ID."
}

variable "vault_url" {
  type        = string
  description = "Azure Key Vault URL containing Zscaler credentials."
}

variable "cc_vm_prov_url" {
  type        = string
  description = "Zscaler provisioning template url."
}

variable "terminate_unhealthy_instances" {
  type        = string
  description = "true/false to indicate whether Azure function should terminate instances that are seen to be unhealthy."
  default     = "true"
}

variable "scheduled_scaling_enabled" {
  type        = bool
  description = "Enable scheduled scaling on top of metric scaling."
  default     = false
}

variable "scheduled_scaling_vmss_min_ccs" {
  type        = number
  description = "Minimum number of CCs in vmss for scheduled scaling profile."
  default     = 2
}

variable "scheduled_scaling_timezone" {
  type        = string
  description = "Timezone the times for the scheduled scaling profile are specified in."
  default     = "Pacific Standard Time"
}

variable "scheduled_scaling_days_of_week" {
  type        = list(string)
  description = "Days of the week to apply scheduled scaling profile."
  default     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
}

variable "scheduled_scaling_start_time_hour" {
  type        = number
  description = "Hour to start scheduled scaling profile."
  default     = 9
}

variable "scheduled_scaling_start_time_min" {
  type        = number
  description = "Minute to start scheduled scaling profile."
  default     = 0
}

variable "scheduled_scaling_end_time_hour" {
  type        = number
  description = "Hour to end scheduled scaling profile."
  default     = 17
}

variable "scheduled_scaling_end_time_min" {
  type        = number
  description = "Minute to end scheduled scaling profile."
  default     = 0
}

variable "zscaler_cc_function_file_path" {
  type        = string
  description = "Path to the zscaler_cc_function file."
}

