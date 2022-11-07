################################################################################
# Create Bastion Host NSG and pre-defined rules
################################################################################
resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "${var.name_prefix}-bastion-nsg-${var.resource_tag}"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "${var.name_prefix}-sec-rule-ssh-${var.resource_tag}"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.bastion_nsg_source_prefix
    destination_address_prefix = "*"
  }

  tags = var.global_tags
}


################################################################################
# Create Public IP to assign to Bastion Host
################################################################################
resource "azurerm_public_ip" "bastion_pip" {
  name                    = "${var.name_prefix}-bastion-public-ip-${var.resource_tag}"
  location                = var.location
  resource_group_name     = var.resource_group
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30

  tags = var.global_tags
}


################################################################################
# Create Network Interface and association NSG
################################################################################
resource "azurerm_network_interface" "bastion_nic" {
  name                = "${var.name_prefix}-bastion-nic-${var.resource_tag}"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "${var.name_prefix}-bastion-nic-conf-${var.resource_tag}"
    subnet_id                     = var.public_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_pip.id
  }

  tags = var.global_tags
}

resource "azurerm_network_interface_security_group_association" "bastion_nic_association" {
  network_interface_id      = azurerm_network_interface.bastion_nic.id
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
}


################################################################################
# Create Bastion Host VM
################################################################################
resource "azurerm_linux_virtual_machine" "bastion_vm" {
  name                  = "${var.name_prefix}-bastion-vm-${var.resource_tag}"
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = [azurerm_network_interface.bastion_nic.id]
  size                  = var.instance_size
  admin_username        = var.server_admin_username
  computer_name         = "${var.name_prefix}-bastion-${var.resource_tag}"
  admin_ssh_key {
    username   = var.server_admin_username
    public_key = "${trimspace(var.ssh_key)} ${var.server_admin_username}@me.io"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.instance_image_publisher
    offer     = var.instance_image_offer
    sku       = var.instance_image_sku
    version   = var.instance_image_version
  }

  tags = var.global_tags

  depends_on = [
    azurerm_network_interface.bastion_nic,
    azurerm_network_interface_security_group_association.bastion_nic_association
  ]
}
