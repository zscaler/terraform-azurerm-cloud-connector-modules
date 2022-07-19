# generate a random string
resource "random_string" "suffix" {
  length = 8
  upper = false
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
  algorithm   = var.tls_key_algorithm
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
  dns_servers    = ["8.8.8.8","8.8.4.4"]
}