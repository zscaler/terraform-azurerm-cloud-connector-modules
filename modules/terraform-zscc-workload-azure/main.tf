resource "azurerm_network_security_group" "server-nsg" {
  count               = var.vm_count
  name                = "${var.name_prefix}-server-${count.index + 1}-nsg-${var.resource_tag}"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "SSH_VNET"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ICMP_VNET"
    priority                   = 4001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "OUTBOUND"
    priority                   = 4000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.global_tags
}

resource "azurerm_network_interface" "server-nic" {
  count                     = var.vm_count
  name                      = "${var.name_prefix}-server-${count.index + 1}-nic-${var.resource_tag}"
  location                  = var.location
  resource_group_name       = var.resource_group

  ip_configuration {
    name                          = "${var.name_prefix}-server-${count.index + 1}-nic-conf-${var.resource_tag}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "dynamic"
  }
  
  #dns_servers = ["8.8.8.8", "8.8.4.4"]
  dns_servers = var.dns_servers
  
  tags = var.global_tags
}

resource "azurerm_network_interface_security_group_association" "server-nic-association" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.server-nic[count.index].id
  network_security_group_id = azurerm_network_security_group.server-nsg[count.index].id
}

resource "azurerm_linux_virtual_machine" "server-vm" {
  count                        = var.vm_count
  name                         = "${var.name_prefix}-server-vm-${count.index + 1}-${var.resource_tag}"
  location                     = var.location
  resource_group_name          = var.resource_group

  network_interface_ids        = [azurerm_network_interface.server-nic[count.index].id]
  size                         = var.instance_size
  admin_username               = var.server_admin_username
  computer_name                = "${var.name_prefix}-server-${count.index + 1}-${var.resource_tag}"
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
    azurerm_network_interface.server-nic,
    azurerm_network_interface_security_group_association.server-nic-association
  ]
}
