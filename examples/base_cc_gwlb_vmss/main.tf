################################################################################
# Generate a unique random string for resource name assignment and key pair
################################################################################
resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}


################################################################################
# Map default tags with values to be assigned to all tagged resources
################################################################################
locals {
  global_tags = {
    Owner       = var.owner_tag
    ManagedBy   = "terraform"
    Vendor      = "Zscaler"
    Environment = var.environment
  }
}


################################################################################
# The following lines generates a new SSH key pair and stores the PEM file 
# locally. The public key output is used as the instance_key passed variable 
# to the vm modules for admin_ssh_key public_key authentication.
# This is not recommended for production deployments. Please consider modifying 
# to pass your own custom public key file located in a secure location.   
################################################################################
# private key for login
resource "tls_private_key" "key" {
  algorithm = var.tls_key_algorithm
}

# write private key to local pem file
resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "../${var.name_prefix}-key-${random_string.suffix.result}.pem"
  file_permission = "0600"
}


################################################################################
# 1. Create/reference all network infrastructure resource dependencies for all 
#    child modules (Resource Group, VNet, Subnets, NAT Gateway, Route Tables)
################################################################################
module "network" {
  source                = "../../modules/terraform-zscc-network-azure"
  name_prefix           = var.name_prefix
  resource_tag          = random_string.suffix.result
  global_tags           = local.global_tags
  location              = var.arm_location
  network_address_space = var.network_address_space
  cc_subnets            = var.cc_subnets
  workloads_subnets     = var.workloads_subnets
  public_subnets        = var.public_subnets
  zones_enabled         = var.zones_enabled
  zones                 = var.zones
  workloads_enabled     = false
  bastion_enabled       = true
}


################################################################################
# 2. Create Bastion Host for workload and CC SSH jump access
################################################################################
module "bastion" {
  source                    = "../../modules/terraform-zscc-bastion-azure"
  location                  = var.arm_location
  name_prefix               = var.name_prefix
  resource_tag              = random_string.suffix.result
  global_tags               = local.global_tags
  resource_group            = module.network.resource_group_name
  public_subnet_id          = module.network.bastion_subnet_ids[0]
  ssh_key                   = tls_private_key.key.public_key_openssh
  bastion_nsg_source_prefix = var.bastion_nsg_source_prefix
}



################################################################################
# 4. Create specified number of CC VMs per vmss_default_ccs by default in an
#    availability set for Azure Data Center fault tolerance. Optionally, deployed
#    CCs can automatically span equally across designated availabilty zones 
#    if enabled via "zones_enabled" and "zones" variables where the number of
#    VMSS created will equal the number of "zones" specified.
#    E.g. 2 zones ['1","2"] and vmss_default_ccs of 2 will create 2x Scale Sets
#    EACH with 2x CCs where VMSS-1 CCs are assigned AZ1 and VMMS-2 CCs in AZ2
################################################################################
# Create the user_data file with necessary bootstrap variables for Cloud Connector registration
locals {
  userdata = <<USERDATA
[ZSCALER]
CC_URL=${var.cc_vm_prov_url}
AZURE_VAULT_URL=${var.azure_vault_url}
HTTP_PROBE_PORT=${var.http_probe_port}
AZURE_MANAGED_IDENTITY_CLIENT_ID=${module.cc_identity.managed_identity_client_id}
VXLAN_EXTERNAL_PORT=${var.vxlan_external_port}
VXLAN_INTERNAL_PORT=${var.vxlan_internal_port}
VXLAN_EXTERNAL_VNI=${var.vxlan_external_vni}
VXLAN_INTERNAL_VNI=${var.vxlan_internal_vni}
USERDATA
}

# Write the file to local filesystem for storage/reference
resource "local_file" "user_data_file" {
  content  = local.userdata
  filename = "../user_data"
}

# Create Flexible Orchestration VMSS and scaling policies
module "cc_vmss" {
  source                         = "../../modules/terraform-zscc-ccvmss-azure"
  location                       = var.arm_location
  name_prefix                    = var.name_prefix
  resource_tag                   = random_string.suffix.result
  global_tags                    = local.global_tags
  resource_group                 = module.network.resource_group_name
  mgmt_subnet_id                 = module.network.cc_subnet_ids
  service_subnet_id              = module.network.cc_subnet_ids
  ssh_key                        = tls_private_key.key.public_key_openssh
  managed_identity_id            = module.cc_identity.managed_identity_id
  user_data                      = local.userdata
  backend_address_pool           = module.cc_gwlb.gwlb_backend_address_pool_id
  zones_enabled                  = var.zones_enabled
  zones                          = var.zones
  ccvm_instance_type             = var.ccvm_instance_type
  ccvm_image_publisher           = var.ccvm_image_publisher
  ccvm_image_offer               = var.ccvm_image_offer
  ccvm_image_sku                 = var.ccvm_image_sku
  ccvm_image_version             = var.ccvm_image_version
  ccvm_source_image_id           = var.ccvm_source_image_id
  mgmt_nsg_id                    = module.cc_nsg.mgmt_nsg_id[0]
  service_nsg_id                 = module.cc_nsg.service_nsg_id[0]
  accelerated_networking_enabled = var.accelerated_networking_enabled
  encryption_at_host_enabled     = var.encryption_at_host_enabled

  vmss_default_ccs    = var.vmss_default_ccs
  vmss_min_ccs        = var.vmss_min_ccs
  vmss_max_ccs        = var.vmss_max_ccs
  scale_out_threshold = var.scale_out_threshold
  scale_in_threshold  = var.scale_in_threshold

  scheduled_scaling_enabled         = var.scheduled_scaling_enabled
  scheduled_scaling_vmss_min_ccs    = var.scheduled_scaling_vmss_min_ccs
  scheduled_scaling_timezone        = var.scheduled_scaling_timezone
  scheduled_scaling_days_of_week    = var.scheduled_scaling_days_of_week
  scheduled_scaling_start_time_hour = var.scheduled_scaling_start_time_hour
  scheduled_scaling_start_time_min  = var.scheduled_scaling_start_time_min
  scheduled_scaling_end_time_hour   = var.scheduled_scaling_end_time_hour
  scheduled_scaling_end_time_min    = var.scheduled_scaling_end_time_min
}

################################################################################
# 5. Create Function App and dependencies for VMSS
################################################################################
module "cc_functionapp" {
  source              = "../../modules/terraform-zscc-function-app-azure"
  name_prefix         = var.name_prefix
  resource_tag        = random_string.suffix.result
  resource_group      = module.network.resource_group_name
  location            = var.arm_location
  global_tags         = local.global_tags
  managed_identity_id = module.cc_identity.function_app_managed_identity_id

  upload_function_app_zip        = var.upload_function_app_zip        #upload local zip from module to Azure Storage Blob
  zscaler_cc_function_public_url = var.zscaler_cc_function_public_url #required if uploading zip to Azure Storage to restrict access
  existing_storage_account       = var.existing_storage_account       #Or pull from pre-existing external URL
  existing_storage_account_name  = var.existing_storage_account_name
  existing_storage_account_rg    = var.existing_storage_account_rg

  #required app_settings inputs
  terminate_unhealthy_instances       = var.terminate_unhealthy_instances
  cc_vm_prov_url                      = var.cc_vm_prov_url
  azure_vault_url                     = var.azure_vault_url
  vmss_names                          = module.cc_vmss.vmss_names
  managed_identity_client_id          = module.cc_identity.function_app_managed_identity_client_id
  existing_log_analytics_workspace    = var.existing_log_analytics_workspace
  existing_log_analytics_workspace_id = var.existing_log_analytics_workspace_id
  run_manual_sync                     = var.run_manual_sync
  path_to_scripts                     = coalesce(var.path_to_scripts, "../../scripts")
  asp_sku_name                        = var.asp_sku_name
}

################################################################################
# 6. Create Network Security Group and rules to be assigned to CC mgmt and 
#    service interface(s). Default behavior will create 1 of each resource per
#    CC VM. Set variable "reuse_nsg" to true if you would like a single NSG 
#    created and assigned to ALL Cloud Connectors
################################################################################
module "cc_nsg" {
  source                 = "../../modules/terraform-zscc-nsg-azure"
  nsg_count              = 1
  name_prefix            = var.name_prefix
  resource_tag           = random_string.suffix.result
  resource_group         = module.network.resource_group_name
  location               = var.arm_location
  global_tags            = local.global_tags
  support_access_enabled = var.support_access_enabled
  gwlb_enabled           = true
  vxlan_internal_port    = var.vxlan_internal_port
  vxlan_external_port    = var.vxlan_external_port
}


################################################################################
# 7. Reference User Managed Identity resource to obtain ID to be assigned to 
#    all Cloud Connectors 
################################################################################
module "cc_identity" {
  source                      = "../../modules/terraform-zscc-identity-azure"
  cc_vm_managed_identity_name = var.cc_vm_managed_identity_name
  cc_vm_managed_identity_rg   = var.cc_vm_managed_identity_rg

  vmss_enabled                       = true
  function_app_managed_identity_name = coalesce(var.function_app_managed_identity_name, var.cc_vm_managed_identity_name)
  function_app_managed_identity_rg   = coalesce(var.function_app_managed_identity_rg, var.cc_vm_managed_identity_rg)

  #optional variable provider block defined in versions.tf to support managed identity resource being in a different subscription
  providers = {
    azurerm = azurerm.managed_identity_sub
  }
}
################################################################################
# Azure Gateway Load Balancer Module
################################################################################
module "cc_gwlb" {
  source         = "../../modules/terraform-zscc-gwlb-azure"
  name_prefix    = var.name_prefix
  resource_tag   = random_string.suffix.result
  global_tags    = local.global_tags
  resource_group = module.network.resource_group_name
  location       = var.arm_location

  # Subnet and NSG configurations for GWLB
  subnet_id = module.network.cc_subnet_ids[0] # Subnet where GWLB is deployed

  # VXLAN settings
  vxlan_external_port = var.vxlan_external_port # UDP port for VXLAN encapsulation (default: 4789)
  vxlan_internal_port = var.vxlan_internal_port # UDP port for VXLAN decapsulation (default: 4789)
  vxlan_external_vni  = var.vxlan_external_vni  # VXLAN External Virtual Network Identifier (VNI)
  vxlan_internal_vni  = var.vxlan_internal_vni  # VXLAN Internal Virtual Network Identifier (VNI)

  # Health probe settings
  health_probe_interval = var.health_probe_interval # Probe interval in seconds (default: 15)
  probe_threshold       = var.probe_threshold       # Number of consecutive probes required (default: 2)
  number_of_probes      = var.number_of_probes
}


################################################################################
# 8. Optionally create a consumer Public Load Balancer chained to the GWLB.
#    If create_consumer_public_lb = true, Terraform creates a new PLB with a Public IP
#    and automatically chains it to the GWLB frontend (no Portal steps needed).
#    If create_consumer_public_lb = false, use the gwlb_frontend_ip_config_id output
#    to manually chain your existing PLB to the GWLB in the Azure Portal.
################################################################################
module "cc_public_lb" {
  count                 = var.create_consumer_public_lb ? 1 : 0
  source                = "../../modules/terraform-zscc-public-lb-azure"
  name_prefix           = var.name_prefix
  resource_tag          = random_string.suffix.result
  global_tags           = local.global_tags
  resource_group        = module.network.resource_group_name
  location              = var.arm_location
  subnet_id             = module.network.cc_subnet_ids[0]
  http_probe_port       = var.http_probe_port
  load_distribution     = var.load_distribution
  zones_enabled         = var.zones_enabled
  zones                 = var.zones
  health_check_interval = var.health_check_interval
  probe_threshold       = var.probe_threshold
  number_of_probes      = var.number_of_probes

  # Automatically chain this PLB to the GWLB frontend
  gateway_load_balancer_frontend_ip_configuration_id = module.cc_gwlb.gwlb_frontend_ip_config_id
}
