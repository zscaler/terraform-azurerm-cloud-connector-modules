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
resource "tls_private_key" "key" {
  algorithm = var.tls_key_algorithm
}

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
  zones_enabled         = var.zones_enabled
  zones                 = var.zones
  #bring-your-own variables
  byo_rg                             = var.byo_rg
  byo_rg_name                        = var.byo_rg_name
  byo_vnet                           = var.byo_vnet
  byo_vnet_name                      = var.byo_vnet_name
  byo_subnets                        = var.byo_subnets
  byo_subnet_names                   = var.byo_subnet_names
  byo_vnet_subnets_rg_name           = var.byo_vnet_subnets_rg_name
  byo_pips                           = var.byo_pips
  byo_pip_names                      = var.byo_pip_names
  byo_pip_rg                         = var.byo_pip_rg
  byo_nat_gws                        = var.byo_nat_gws
  byo_nat_gw_names                   = var.byo_nat_gw_names
  byo_nat_gw_rg                      = var.byo_nat_gw_rg
  existing_nat_gw_pip_association    = var.existing_nat_gw_pip_association
  existing_nat_gw_subnet_association = var.existing_nat_gw_subnet_association
}


################################################################################
# 2. Create specified number of CC VMs per cc_count by default in an
#    availability set for Azure Data Center fault tolerance. Optionally, deployed
#    CCs can automatically span equally across designated availability zones
#    if enabled via "zones_enabled" and "zones" variables. E.g. cc_count set to
#    4 and 2 zones ["1","2"] will create 2x CCs in AZ1 and 2x CCs in AZ2
################################################################################
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

resource "local_file" "user_data_file" {
  content  = local.userdata
  filename = "../user_data"
}

locals {
  arm_location_lower_case          = lower(var.arm_location)
  is_china                         = can(regex("^china", local.arm_location_lower_case))
  conditional_ccvm_image_publisher = local.is_china ? "cbcnetworks" : var.ccvm_image_publisher
  conditional_ccvm_image_offer     = local.is_china ? "zscaler-cloud-connector" : var.ccvm_image_offer
}

module "cc_vm" {
  source                         = "../../modules/terraform-zscc-ccvm-azure"
  cc_count                       = var.cc_count
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
  lb_association_enabled         = true
  location                       = var.arm_location
  zones_enabled                  = var.zones_enabled
  zones                          = var.zones
  ccvm_instance_type             = var.ccvm_instance_type
  ccvm_image_publisher           = local.conditional_ccvm_image_publisher
  ccvm_image_offer               = local.conditional_ccvm_image_offer
  ccvm_image_sku                 = var.ccvm_image_sku
  ccvm_image_version             = var.ccvm_image_version
  ccvm_source_image_id           = var.ccvm_source_image_id
  mgmt_nsg_id                    = module.cc_nsg.mgmt_nsg_id
  service_nsg_id                 = module.cc_nsg.service_nsg_id
  accelerated_networking_enabled = var.accelerated_networking_enabled
  encryption_at_host_enabled     = var.encryption_at_host_enabled
}


################################################################################
# 3. Create Network Security Group and rules to be assigned to CC mgmt and
#    service interface(s). Default behavior will create 1 of each resource per
#    CC VM. Set variable "reuse_nsg" to true if you would like a single NSG
#    created and assigned to ALL Cloud Connectors
################################################################################
module "cc_nsg" {
  source                 = "../../modules/terraform-zscc-nsg-azure"
  nsg_count              = var.reuse_nsg == false ? var.cc_count : 1
  name_prefix            = var.name_prefix
  resource_tag           = random_string.suffix.result
  resource_group         = var.byo_nsg == false ? module.network.resource_group_name : var.byo_nsg_rg
  location               = var.arm_location
  global_tags            = local.global_tags
  support_access_enabled = var.support_access_enabled
  zssupport_server       = var.zssupport_server
  gwlb_enabled           = true
  vxlan_internal_port    = var.vxlan_internal_port
  vxlan_external_port    = var.vxlan_external_port

  byo_nsg = var.byo_nsg
  # optional inputs. only required if byo_nsg set to true
  byo_mgmt_nsg_names    = var.byo_mgmt_nsg_names
  byo_service_nsg_names = var.byo_service_nsg_names
  # optional inputs. only required if byo_nsg set to true
}


################################################################################
# 4. Reference User Managed Identity resource to obtain ID to be assigned to
#    all Cloud Connectors
################################################################################
module "cc_identity" {
  source                      = "../../modules/terraform-zscc-identity-azure"
  cc_vm_managed_identity_name = var.cc_vm_managed_identity_name
  cc_vm_managed_identity_rg   = var.cc_vm_managed_identity_rg

  # TF-AZ-10 (opt-in): create and assign a least-privilege Custom Role for the CC
  # managed identity instead of relying on an out-of-band role assignment.
  cc_resource_group_name = module.network.resource_group_name
  create_cc_read_role    = var.create_cc_read_role
  cc_read_role_name      = var.cc_read_role_name

  providers = {
    azurerm.managed_identity_sub = azurerm.managed_identity_sub
  }
}


################################################################################
# 5. Create Azure Gateway Load Balancer in CC subnet with VXLAN tunnel
#    interfaces, health probe, and load balancing rule
################################################################################
module "cc_gwlb" {
  source                = "../../modules/terraform-zscc-gwlb-azure"
  name_prefix           = var.name_prefix
  resource_tag          = random_string.suffix.result
  global_tags           = local.global_tags
  resource_group        = module.network.resource_group_name
  location              = var.arm_location
  subnet_id             = module.network.cc_subnet_ids[0]
  vxlan_external_port   = var.vxlan_external_port
  vxlan_internal_port   = var.vxlan_internal_port
  vxlan_external_vni    = var.vxlan_external_vni
  vxlan_internal_vni    = var.vxlan_internal_vni
  http_probe_port       = var.http_probe_port
  health_probe_interval = var.health_probe_interval
  probe_threshold       = var.probe_threshold
  zones_enabled         = var.zones_enabled
  zones                 = var.zones
}


################################################################################
# 6. Optionally create a consumer Public Load Balancer chained to the GWLB.
#    If create_consumer_public_lb = true, Terraform creates a new PLB with a Public IP
#    and automatically chains it to the GWLB frontend (no Portal steps needed).
#    If create_consumer_public_lb = false, use the gwlb_frontend_ip_config_id output
#    to manually chain your existing PLB to the GWLB in the Azure Portal.
################################################################################
module "cc_public_lb" {
  count           = var.create_consumer_public_lb ? 1 : 0
  source          = "../../modules/terraform-zscc-public-lb-azure"
  name_prefix     = var.name_prefix
  resource_tag    = random_string.suffix.result
  global_tags     = local.global_tags
  resource_group  = module.network.resource_group_name
  location        = var.arm_location
  subnet_id       = module.network.cc_subnet_ids[0]
  http_probe_port = var.http_probe_port
  zones_enabled   = var.zones_enabled
  zones           = var.zones

  # Automatically chain this PLB to the GWLB frontend
  gateway_load_balancer_frontend_ip_configuration_id = module.cc_gwlb.gwlb_frontend_ip_config_id
}
