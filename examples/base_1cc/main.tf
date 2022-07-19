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
#### as the ssh_key passed variable to the cc_vm module for admin_ssh_key public_key authentication                     ####
#### This is not recommended for production deployments. Please consider modifying to pass your own custom              ####
#### public key file located in a secure location                                                                       ####
############################################################################################################################
# private key for login
resource "tls_private_key" "key" {
  algorithm = var.tls_key_algorithm
}

# save the private key
resource "null_resource" "save-key" {
  triggers = {
    key = tls_private_key.key.private_key_pem
  }

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
# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.name_prefix}-rg-${random_string.suffix.result}"
  location = var.arm_location

  tags = local.global_tags
}


# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name_prefix}-vnet-${random_string.suffix.result}"
  address_space       = [var.network_address_space]
  location            = var.arm_location
  resource_group_name = azurerm_resource_group.main.name

  tags = local.global_tags
}

# Create Bastion Host public subnet
resource "azurerm_subnet" "bastion-subnet" {
  name                 = "${var.name_prefix}-bastion-subnet-${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.network_address_space, 8, 101)]
}

# Create Workload Subnet
resource "azurerm_subnet" "workload-subnet" {
  name                 = "${var.name_prefix}-workload-subnet-${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.network_address_space, 8, 1)]
}


# Create Public IPs for NAT Gateways
resource "azurerm_public_ip" "nat-pip" {
  count                   = length(azurerm_subnet.cc-subnet.*.id)
  name                    = "${var.name_prefix}-nat-gw-public-ip-${count.index + 1}-${random_string.suffix.result}"
  location                = var.arm_location
  resource_group_name     = azurerm_resource_group.main.name
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 30
  availability_zone       = local.zones_supported ? element(var.zones, count.index) : local.pip_zones

  tags = local.global_tags

  depends_on = [
    azurerm_subnet.cc-subnet
  ]
}


# Create NAT Gateways
resource "azurerm_nat_gateway" "nat-gw" {
  count                   = length(distinct(var.zones))
  name                    = "${var.name_prefix}-nat-gw-${count.index + 1}-${random_string.suffix.result}"
  location                = var.arm_location
  resource_group_name     = azurerm_resource_group.main.name
  idle_timeout_in_minutes = 10
  zones                   = local.zones_supported ? [element(var.zones, count.index)] : null

  tags = local.global_tags
}


# Associate Public IP to NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "nat-gw-association1" {
  count                = length(azurerm_nat_gateway.nat-gw.*.id)
  nat_gateway_id       = azurerm_nat_gateway.nat-gw.*.id[count.index]
  public_ip_address_id = azurerm_public_ip.nat-pip.*.id[count.index]

  depends_on = [
    azurerm_public_ip.nat-pip,
    azurerm_nat_gateway.nat-gw
  ]
}

# 2. Create Bastion Host
module "bastion" {
  source           = "../../modules/terraform-zscc-bastion-azure"
  location         = var.arm_location
  name_prefix      = var.name_prefix
  resource_tag     = random_string.suffix.result
  global_tags      = local.global_tags
  resource_group   = azurerm_resource_group.main.name
  public_subnet_id = azurerm_subnet.bastion-subnet.id
  ssh_key          = tls_private_key.key.public_key_openssh
}

# 3. Create Workloads
module "workload" {
  source         = "../../modules/terraform-zscc-workload-azure"
  vm_count       = var.vm_count
  location       = var.arm_location
  name_prefix    = var.name_prefix
  resource_tag   = random_string.suffix.result
  global_tags    = local.global_tags
  resource_group = azurerm_resource_group.main.name
  subnet_id      = azurerm_subnet.workload-subnet.id
  ssh_key        = tls_private_key.key.public_key_openssh
  dns_servers    = ["8.8.8.8", "8.8.4.4"]
}



# 4. Create CC network, routing, and appliance
# Create Cloud Connector Subnets
resource "azurerm_subnet" "cc-subnet" {
  count                = 1
  name                 = "${var.name_prefix}-cc-subnet-${count.index + 1}-${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.cc_subnets != null ? [element(var.cc_subnets, count.index)] : [cidrsubnet(var.network_address_space, 8, count.index + 200)]
}


# Associate Cloud Connector Subnet to NAT Gateway
resource "azurerm_subnet_nat_gateway_association" "subnet-nat-association-ec" {
  count          = length(azurerm_subnet.cc-subnet.*.id)
  subnet_id      = azurerm_subnet.cc-subnet.*.id[count.index]
  nat_gateway_id = azurerm_nat_gateway.nat-gw.*.id[count.index]

  depends_on = [
    azurerm_subnet.cc-subnet,
    azurerm_nat_gateway.nat-gw
  ]
}


# Validation for Cloud Connector instance size and Azure VM Instance Type compatibilty. A file will get generated in root path if this error gets triggered.
resource "null_resource" "cc-error-checker" {
  count = local.valid_cc_create ? 0 : 1 # 0 means no error is thrown, else throw error
  provisioner "local-exec" {
    command = <<EOF
      echo "Cloud Connector parameters were invalid. No appliances were created. Please check the documentation and cc_instance_size / ccvm_instance_type values that were chosen" >> ../errorlog.txt
EOF
  }
}

# Cloud Connector Module variables
# Create 1 CC VM
module "cc-vm" {
  source                         = "../../modules/terraform-zscc-ccvm-azure"
  name_prefix                    = var.name_prefix
  resource_tag                   = random_string.suffix.result
  global_tags                    = local.global_tags
  resource_group                 = azurerm_resource_group.main.name
  mgmt_subnet_id                 = azurerm_subnet.cc-subnet.*.id
  service_subnet_id              = azurerm_subnet.cc-subnet.*.id
  ssh_key                        = tls_private_key.key.public_key_openssh
  managed_identity_id            = module.cc-identity.managed_identity_id
  user_data                      = local.userdata
  location                       = var.arm_location
  zones_enabled                  = var.zones_enabled
  zones                          = var.zones
  ccvm_instance_type             = var.ccvm_instance_type
  ccvm_image_publisher           = var.ccvm_image_publisher
  ccvm_image_offer               = var.ccvm_image_offer
  ccvm_image_sku                 = var.ccvm_image_sku
  ccvm_image_version             = var.ccvm_image_version
  cc_instance_size               = var.cc_instance_size
  mgmt_nsg_id                    = module.cc-nsg.mgmt_nsg_id
  service_nsg_id                 = module.cc-nsg.service_nsg_id
  accelerated_networking_enabled = var.accelerated_networking_enabled

  depends_on = [
    azurerm_subnet_nat_gateway_association.subnet-nat-association-ec,
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
  resource_group = azurerm_resource_group.main.name
  location       = var.arm_location
  global_tags    = local.global_tags
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

# Create Workload Route Table to send to Cloud Connector
resource "azurerm_route_table" "workload-rt" {
  name                = "${var.name_prefix}-workload-rt-${random_string.suffix.result}"
  location            = var.arm_location
  resource_group_name = azurerm_resource_group.main.name

  disable_bgp_route_propagation = true

  route {
    name                   = "default-to-cc"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = module.cc-vm.service_ip[0]
  }
}

# Associate Route Table with Workload Subnet
resource "azurerm_subnet_route_table_association" "server-rt-assoc" {
  subnet_id      = azurerm_subnet.workload-subnet.id
  route_table_id = azurerm_route_table.workload-rt.id
}