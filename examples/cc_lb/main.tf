# generate a random string
resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}


# Map default tags with values to be assigned to all tagged resources
locals {
  global_tags = {
    Owner       = var.owner_tag
    ManagedBy   = "terraform"
    Vendor      = "Zscaler"
    Environment = var.environment
  }
}

############################################################################################################################
#### The following lines generates a new SSH key pair and stores the PEM file locally. The public key output is used    ####
#### as the ssh_key passed variable to the cc-vm module for admin_ssh_key public_key authentication                     ####
#### This is not recommended for production deployments. Please consider modifying to pass your own custom              ####
#### public key file located in a secure location                                                                       ####
############################################################################################################################
# Generate a new private key for ssh login to Cloud Connector
resource "tls_private_key" "key" {
  algorithm = var.tls_key_algorithm
}

# save the private key locally
resource "null_resource" "save-key" {
  triggers = {
    key = tls_private_key.key.private_key_pem
  }

  # set key file to appropriate execution permissions
  provisioner "local-exec" {
    command = <<EOF
      echo "${tls_private_key.key.private_key_pem}" > ../${var.name_prefix}-key-${random_string.suffix.result}.pem
      chmod 0600 ../${var.name_prefix}-key-${random_string.suffix.result}.pem
EOF
  }
}

###########################################################################################################################
###########################################################################################################################

## Create the user_data file
locals {
  userdata = <<USERDATA
[ZSCALER]
CC_URL=${var.cc_vm_prov_url}
AZURE_VAULT_URL=${var.azure_vault_url}
HTTP_PROBE_PORT=${var.http_probe_port}
USERDATA
}

resource "local_file" "user-data-file" {
  content  = local.userdata
  filename = "../user_data"
}


# 1. Network Infra
# Create Resource Group or reference existing
resource "azurerm_resource_group" "main" {
  count    = var.byo_rg == false ? 1 : 0
  name     = "${var.name_prefix}-rg-${random_string.suffix.result}"
  location = var.arm_location

  tags = local.global_tags
}

data "azurerm_resource_group" "selected" {
  name = var.byo_rg == false ? azurerm_resource_group.main.*.name[0] : var.byo_rg_name
}


# Create Virtual Network or reference existing
resource "azurerm_virtual_network" "vnet" {
  count               = var.byo_vnet == false ? 1 : 0
  name                = "${var.name_prefix}-vnet-${random_string.suffix.result}"
  address_space       = [var.network_address_space]
  location            = var.arm_location
  resource_group_name = data.azurerm_resource_group.selected.name

  tags = local.global_tags
}

data "azurerm_virtual_network" "selected" {
  name                = var.byo_vnet == false ? azurerm_virtual_network.vnet.*.name[0] : var.byo_vnet_name
  resource_group_name = var.byo_vnet == false ? azurerm_virtual_network.vnet.*.resource_group_name[0] : var.byo_vnet_subnets_rg_name
}



# Create Public IP for NAT Gateway or reference existing
resource "azurerm_public_ip" "nat-pip" {
  count                   = var.byo_pips == false ? length(distinct(var.zones)) : 0
  name                    = "${var.name_prefix}-nat-gw-public-ip-${count.index + 1}-${random_string.suffix.result}"
  location                = var.arm_location
  resource_group_name     = data.azurerm_resource_group.selected.name
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 30
  availability_zone       = local.zones_supported ? element(var.zones, count.index) : local.pip_zones

  tags = local.global_tags
}

data "azurerm_public_ip" "selected" {
  count               = var.byo_pips == false ? length(azurerm_public_ip.nat-pip.*.id) : length(var.byo_pip_names)
  name                = var.byo_pips == false ? azurerm_public_ip.nat-pip.*.name[count.index] : element(var.byo_pip_names, count.index)
  resource_group_name = var.byo_pips == false ? data.azurerm_resource_group.selected.name : var.byo_pip_rg
}


# Create NAT Gateway or reference an existing
resource "azurerm_nat_gateway" "nat-gw" {
  count                   = var.byo_nat_gws == false ? length(distinct(var.zones)) : 0
  name                    = "${var.name_prefix}-nat-gw-${count.index + 1}-${random_string.suffix.result}"
  location                = var.arm_location
  resource_group_name     = data.azurerm_resource_group.selected.name
  idle_timeout_in_minutes = 10
  zones                   = local.zones_supported ? [element(var.zones, count.index)] : null

  tags = local.global_tags
}

data "azurerm_nat_gateway" "selected" {
  count               = var.byo_nat_gws == false ? length(azurerm_nat_gateway.nat-gw.*.id) : length(var.byo_nat_gw_names)
  name                = var.byo_nat_gws == false ? azurerm_nat_gateway.nat-gw.*.name[count.index] : element(var.byo_nat_gw_names, count.index)
  resource_group_name = var.byo_nat_gws == false ? data.azurerm_resource_group.selected.name : var.byo_nat_gw_rg
}

# Associate Public IP to NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "nat-gw-association1" {
  count                = var.existing_nat_gw_pip_association == false ? length(data.azurerm_nat_gateway.selected.*.id) : 0
  nat_gateway_id       = data.azurerm_nat_gateway.selected.*.id[count.index]
  public_ip_address_id = data.azurerm_public_ip.selected.*.id[count.index]

  depends_on = [
    data.azurerm_public_ip.selected,
    data.azurerm_nat_gateway.selected
  ]
}



# 2. Create CC network, routing, and appliance
# Create Cloud Connector Subnet
resource "azurerm_subnet" "cc-subnet" {
  count                = var.byo_subnets == false ? length(distinct(var.zones)) : 0
  name                 = "${var.name_prefix}-cc-subnet-${count.index + 1}-${random_string.suffix.result}"
  resource_group_name  = var.byo_vnet == false ? data.azurerm_virtual_network.selected.resource_group_name : var.byo_vnet_subnets_rg_name
  virtual_network_name = var.byo_vnet == false ? data.azurerm_virtual_network.selected.name : var.byo_vnet_name
  address_prefixes     = var.cc_subnets != null ? [element(var.cc_subnets, count.index)] : [cidrsubnet(var.network_address_space, 8, count.index + 200)]
}

# Or reference an existing subnet
data "azurerm_subnet" "cc-selected" {
  count                = var.byo_subnets == false ? length(azurerm_subnet.cc-subnet.*.id) : length(var.byo_subnet_names)
  name                 = var.byo_subnets == false ? azurerm_subnet.cc-subnet.*.name[count.index] : element(var.byo_subnet_names, count.index)
  resource_group_name  = var.byo_vnet == false ? data.azurerm_virtual_network.selected.resource_group_name : var.byo_vnet_subnets_rg_name
  virtual_network_name = var.byo_vnet == false ? data.azurerm_virtual_network.selected.name : var.byo_vnet_name
}



# Associate Cloud Connector Subnet to NAT Gateway
resource "azurerm_subnet_nat_gateway_association" "subnet-nat-association-ec" {
  count          = var.existing_nat_gw_subnet_association == false ? length(data.azurerm_subnet.cc-selected.*.id) : 0
  subnet_id      = data.azurerm_subnet.cc-selected.*.id[count.index]
  nat_gateway_id = data.azurerm_nat_gateway.selected.*.id[count.index]

  depends_on = [
    data.azurerm_subnet.cc-selected,
    data.azurerm_nat_gateway.selected
  ]
}


# Validation for Cloud Connector instance size and Azure VM Instance Type compatibilty. A file will get generated in root path if this error gets triggered.
resource "null_resource" "cc-error-checker" {
  count = local.valid_cc_create ? 0 : 1 # 0 means no error is thrown, else throw error
  provisioner "local-exec" {
    command = <<EOF
      echo "Cloud Connector parameters were invalid. No appliances were created. Please check the documentation and cc_instance_size / ccvm_instance_type values that were chosen" >> ./errorlog.txt
EOF
  }
}

# Cloud Connector Module variables
# Create X CC VMs per cc_count by default in an availability set for Azure data center fault tolerance.
# Optionally create X CC VMs per cc_count which will span equally across designated availability zones specified in zones_enables
# zones variables.
# E.g. cc_count set to 4 and 2 zones ['1","2"] will create 2x CCs in AZ1 and 2x CCs in AZ2
module "cc-vm" {
  cc_count               = var.cc_count
  source                 = "../../modules/terraform-zscc-ccvm-azure"
  name_prefix            = var.name_prefix
  resource_tag           = random_string.suffix.result
  global_tags            = local.global_tags
  resource_group         = data.azurerm_resource_group.selected.name
  mgmt_subnet_id         = data.azurerm_subnet.cc-selected.*.id
  service_subnet_id      = data.azurerm_subnet.cc-selected.*.id
  ssh_key                = tls_private_key.key.public_key_openssh
  managed_identity_id    = module.cc-identity.managed_identity_id
  user_data              = local.userdata
  backend_address_pool   = module.cc-lb.lb_backend_address_pool
  lb_association_enabled = true
  location               = var.arm_location
  zones_enabled          = var.zones_enabled
  zones                  = var.zones
  ccvm_instance_type     = var.ccvm_instance_type
  ccvm_image_publisher   = var.ccvm_image_publisher
  ccvm_image_offer       = var.ccvm_image_offer
  ccvm_image_sku         = var.ccvm_image_sku
  ccvm_image_version     = var.ccvm_image_version
  cc_instance_size       = var.cc_instance_size
  mgmt_nsg_id            = module.cc-nsg.mgmt_nsg_id
  service_nsg_id         = module.cc-nsg.service_nsg_id

  depends_on = [
    local_file.user-data-file,
  ]
}


# Create Network Security Group and rules to be assigned to CC mgmt and and service interface(s). Default behavior will create 1 of each resource per CC VM. Set variable reuse_nsg
# to true if you would like a single security group created and assigned to ALL Cloud Connectors
module "cc-nsg" {
  source         = "../../modules/terraform-zscc-nsg-azure"
  nsg_count      = var.reuse_nsg == false ? var.cc_count : 1
  name_prefix    = var.name_prefix
  resource_tag   = random_string.suffix.result
  resource_group = var.byo_nsg == false ? data.azurerm_resource_group.selected.name : var.byo_nsg_rg
  location       = var.arm_location
  global_tags    = local.global_tags

  byo_nsg = var.byo_nsg
  # optional inputs. only required if byo_nsg set to true
  byo_mgmt_nsg_names    = var.byo_mgmt_nsg_names
  byo_service_nsg_names = var.byo_service_nsg_names
  # optional inputs. only required if byo_nsg set to true
}


# Reference User Managed Identity resource to obtain ID to be assigned to all Cloud Connectors
module "cc-identity" {
  source                      = "../../modules/terraform-zscc-identity-azure"
  cc_vm_managed_identity_name = var.cc_vm_managed_identity_name
  cc_vm_managed_identity_rg   = var.cc_vm_managed_identity_rg

  #optional variable provider block defined in versions.tf to support managed identity resource being in a different subscription
  providers = {
    azurerm = azurerm.managed_identity_sub
  }
}


# Azure Load Balancer Module variables
module "cc-lb" {
  source            = "../../modules/terraform-zscc-lb-azure"
  name_prefix       = var.name_prefix
  resource_tag      = random_string.suffix.result
  global_tags       = local.global_tags
  resource_group    = data.azurerm_resource_group.selected.name
  location          = var.arm_location
  subnet_id         = data.azurerm_subnet.cc-selected.*.id[0]
  http_probe_port   = var.http_probe_port
  load_distribution = var.load_distribution
}