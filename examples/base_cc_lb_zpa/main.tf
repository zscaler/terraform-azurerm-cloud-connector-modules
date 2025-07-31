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
  private_dns_subnet    = var.private_dns_subnet
  zones_enabled         = var.zones_enabled
  zones                 = var.zones
  lb_frontend_ip        = module.cc_lb.lb_ip
  workloads_enabled     = true
  bastion_enabled       = true
  lb_enabled            = var.lb_enabled
  zpa_enabled           = var.zpa_enabled
  vwan_hub_id           = var.vwan_hub_id
  vnet_connection_name  = var.vnet_connection_name
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
# 3. Create Workload Hosts to test traffic connectivity through CC
################################################################################
module "workload" {
  source         = "../../modules/terraform-zscc-workload-azure"
  workload_count = var.workload_count
  location       = var.arm_location
  name_prefix    = var.name_prefix
  resource_tag   = random_string.suffix.result
  global_tags    = local.global_tags
  resource_group = module.network.resource_group_name
  subnet_id      = module.network.workload_subnet_ids[0]
  ssh_key        = tls_private_key.key.public_key_openssh
  dns_servers    = []
}


################################################################################
# 4. Create specified number of CC VMs per cc_count by default in an
#    availability set for Azure Data Center fault tolerance. Optionally, deployed
#    CCs can automatically span equally across designated availabilty zones 
#    if enabled via "zones_enabled" and "zones" variables. E.g. cc_count set to 
#    4 and 2 zones ['1","2"] will create 2x CCs in AZ1 and 2x CCs in AZ2
################################################################################
# Create the user_data file with necessary bootstrap variables for Cloud Connector registration
locals {
  userdata = <<USERDATA
[ZSCALER]
CC_URL=${var.cc_vm_prov_url}
AZURE_VAULT_URL=${var.azure_vault_url}
HTTP_PROBE_PORT=${var.http_probe_port}
AZURE_MANAGED_IDENTITY_CLIENT_ID=${module.cc_identity.managed_identity_client_id}
[BGPCONFIG]
LB_VIP=${module.cc_lb.lb_ip}
VWAN_HUB_ID=${var.vwan_hub_id}
VNET_CONNECTION_ID=${module.network.virtual_network_vwan_connection_id}
USERDATA
}

# Write the file to local filesystem for storage/reference
resource "local_file" "user_data_file" {
  content  = local.userdata
  filename = "../user_data"
}

# Validates which Marketplace to use based on arm location
locals {
  arm_location_lower_case          = lower(var.arm_location)
  is_china                         = can(regex("^china", local.arm_location_lower_case))
  conditional_ccvm_image_publisher = local.is_china ? "cbcnetworks" : var.ccvm_image_publisher
  conditional_ccvm_image_offer     = local.is_china ? "zscaler-cloud-connector" : var.ccvm_image_offer
}

# Create specified number of CC appliances
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
  backend_address_pool           = module.cc_lb.lb_backend_address_pool
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
# 5. Create Network Security Group and rules to be assigned to CC mgmt and 
#    service interface(s). Default behavior will create 1 of each resource per
#    CC VM. Set variable "reuse_nsg" to true if you would like a single NSG 
#    created and assigned to ALL Cloud Connectors
################################################################################
module "cc_nsg" {
  source                 = "../../modules/terraform-zscc-nsg-azure"
  nsg_count              = var.reuse_nsg == false ? var.cc_count : 1
  name_prefix            = var.name_prefix
  resource_tag           = random_string.suffix.result
  resource_group         = module.network.resource_group_name
  location               = var.arm_location
  global_tags            = local.global_tags
  support_access_enabled = var.support_access_enabled
  zssupport_server       = var.zssupport_server
}


################################################################################
# 6. Reference User Managed Identity resource to obtain ID to be assigned to 
#    all Cloud Connectors 
################################################################################
module "cc_identity" {
  source                      = "../../modules/terraform-zscc-identity-azure"
  cc_vm_managed_identity_name = var.cc_vm_managed_identity_name
  cc_vm_managed_identity_rg   = var.cc_vm_managed_identity_rg

  #optional variable provider block defined in versions.tf to support managed identity resource being in a different subscription
  providers = {
    azurerm = azurerm.managed_identity_sub
  }
}


################################################################################
# 7. Create Azure Load Balancer in CC VNet with all Backend Pools, Rules, and 
#    Health Probes
################################################################################
# Azure Load Balancer Module variables
module "cc_lb" {
  source                = "../../modules/terraform-zscc-lb-azure"
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
}


################################################################################
# 8. Create Azure Private DNS Resolver Ruleset, Rules, and Outbound Endpoint
#    for utilization with DNS redirection/conditional forwarding to Cloud
#    Connector to enabling ZPA and/or ZIA DNS control features.
################################################################################
module "private_dns" {
  source                = "../../modules/terraform-zscc-private-dns-azure"
  name_prefix           = var.name_prefix
  resource_tag          = random_string.suffix.result
  global_tags           = local.global_tags
  resource_group        = module.network.resource_group_name
  location              = var.arm_location
  vnet_id               = module.network.virtual_network_id
  private_dns_subnet_id = module.network.private_dns_subnet_id
  domain_names          = var.domain_names
  target_address        = var.target_address
}

################################################################################
# Optional: Create Azure Private DNS Resolver Virtual Network Link
# This resource is getting created for greenfield deployments since
# workloads are being deployed in the same VNet as the Cloud Connectors.

# Generally, this would only be created and associated with spoke VNets in
# centralized hub-spoke topologies. Be careful what domains are used in rule
# creation to avoid DNS loops.
################################################################################
resource "azurerm_private_dns_resolver_virtual_network_link" "dns_vnet_link" {
  name                      = "${var.name_prefix}-vnet-link-${random_string.suffix.result}"
  dns_forwarding_ruleset_id = module.private_dns.private_dns_forwarding_ruleset_id
  virtual_network_id        = module.network.virtual_network_id
}
