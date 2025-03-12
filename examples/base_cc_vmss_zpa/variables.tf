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
  description = "VNet IP CIDR Range. All subnet resources that might get created (public, workload, cloud connector) are derived from this /16 CIDR. If you require creating a VNet smaller than /16, you may need to explicitly define all other subnets via public_subnets, workload_subnets, cc_subnets, and route53_subnets variables"
  default     = "10.1.0.0/16"
}

variable "cc_subnets" {
  type        = list(string)
  description = "Cloud Connector Subnets to create in VNet. This is only required if you want to override the default subnets that this code creates via network_address_space variable."
  default     = null
}

variable "workloads_subnets" {
  type        = list(string)
  description = "Workload Subnets to create in VNet. This is only required if you want to override the default subnets that this code creates via network_address_space variable."
  default     = null
}

variable "public_subnets" {
  type        = list(string)
  description = "Public/Bastion Subnets to create in VNet. This is only required if you want to override the default subnets that this code creates via network_address_space variable."
  default     = null
}

variable "private_dns_subnet" {
  type        = string
  description = "Private DNS Resolver Outbound Endpoint Subnet to create in VNet. This is only required if you want to override the default subnet that this code creates via network_address_space variable."
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

variable "workload_count" {
  type        = number
  description = "The number of Workload VMs to deploy"
  default     = 1
  validation {
    condition     = var.workload_count >= 1 && var.workload_count <= 250
    error_message = "Input workload_count must be a whole number between 1 and 250."
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

variable "accelerated_networking_enabled" {
  type        = bool
  description = "Enable/Disable accelerated networking support on all Cloud Connector service interfaces"
  default     = true
}

variable "bastion_nsg_source_prefix" {
  type        = string
  description = "user input for locking down SSH access to bastion to a specific IP or CIDR range"
  default     = "*"
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

variable "vmss_default_ccs" {
  type        = number
  description = "Default number of CCs in vmss."
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

variable "scale_out_threshold" {
  type        = number
  description = "Metric threshold for determining scale out."
  default     = 70
}

variable "scale_in_threshold" {
  type        = number
  description = "Metric threshold for determining scale in."
  default     = 50
}

variable "terminate_unhealthy_instances" {
  type        = bool
  description = "Indicate whether detected unhealthy instances are terminated or not."
  default     = true
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

variable "upload_function_app_zip" {
  type        = bool
  description = "By default, this Terraform will create a new Storage Account/Container/Blob to upload the zip file. The function app will pull from the blobl url to run. Setting this value to false will prevent creation/upload of the blob file"
  default     = true
}

variable "zscaler_cc_function_public_url" {
  type        = string
  description = "Publicly accessible URL path where Function App can pull its zip file build from. This is only required when var.upload_function_app_zip is set to false"
  default     = ""
}

variable "existing_storage_account" {
  type        = bool
  description = "Set to True if you wish to use an existing Storage Account to associate with the Function App. Default is false meaning Terraform module will create a new one"
  default     = false
}

variable "existing_storage_account_name" {
  type        = string
  description = "Name of existing Storage Account to associate with the Function App."
  default     = ""
}

variable "existing_storage_account_rg" {
  type        = string
  description = "Resource Group of existing Storage Account to associate with the Function App."
  default     = ""
}

variable "function_app_managed_identity_name" {
  type        = string
  description = "Azure Managed Identity name to attach to the Function App. E.g zspreview-66117-mi"
  default     = ""
}

variable "function_app_managed_identity_rg" {
  type        = string
  description = "Resource Group of the Azure Managed Identity name to attach to the Function App. E.g. edgeconnector_rg_1"
  default     = ""
}

variable "existing_log_analytics_workspace" {
  type        = bool
  description = "Set to True if you wish to use an existing Log Analytics Workspace to associate with the AppInsights Instance. Default is false meaning Terraform module will create a new one"
  default     = false
}

variable "existing_log_analytics_workspace_id" {
  type        = string
  description = "ID of existing Log Analytics Workspace to associate with the AppInsights Instance."
  default     = ""
}


# Azure Private DNS specific variables
variable "zpa_enabled" {
  type        = bool
  description = "Configure Azure Private DNS Outbound subnet, Resolvers, Rulesets/Rules, and Outbound Endpoint ZPA DNS redirection"
  default     = true
}

variable "domain_names" {
  type        = map(any)
  description = "Domain names fqdn/wildcard to have Azure Private DNS redirect DNS requests to Cloud Connector"
}

variable "target_address" {
  type        = list(string)
  description = "Azure DNS queries will be conditionally forwarded to these target IP addresses. Default are a pair of Zscaler Global VIP addresses"
  default     = ["185.46.212.88", "185.46.212.89"]
}

variable "run_manual_sync" {
  type        = bool
  description = "Set to True if you would like terraform to run the manual sync operation to start the Function App after creation. The alternative is to navigate to the Function App on the Azure Portal UI or to manually invoke the script yourself."
  default     = true
}

variable "path_to_scripts" {
  type        = string
  description = "Path to script_directory"
  default     = ""
}

variable "asp_sku_name" {
  type        = string
  description = "SKU Name for the App Service Plan. Recommended Y1 (flex consumption) for function app unless not supported by Azure region"
  default     = "Y1"
  validation {
    condition = (
      var.asp_sku_name == "Y1" ||
      var.asp_sku_name == "FC1" ||
      var.asp_sku_name == "EP1" ||
      var.asp_sku_name == "B1"
    )
    error_message = "Input asp_sku_name selected is not a valid/approved SKU Name."
  }
}
