################################################################################
# Create NSG and Rules for worload VMs
################################################################################
resource "azurerm_network_security_group" "workload_nsg" {
  count               = var.workload_count
  name                = "${var.name_prefix}-workload-${count.index + 1}-nsg-${var.resource_tag}"
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


################################################################################
# Create Network Interface and association NSG
################################################################################
resource "azurerm_network_interface" "workload_nic" {
  count               = var.workload_count
  name                = "${var.name_prefix}-workload-${count.index + 1}-nic-${var.resource_tag}"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "${var.name_prefix}-workload-${count.index + 1}-nic-conf-${var.resource_tag}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  dns_servers = var.dns_servers

  tags = var.global_tags
}

resource "azurerm_network_interface_security_group_association" "workload_nic_association" {
  count                     = var.workload_count
  network_interface_id      = azurerm_network_interface.workload_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.workload_nsg[count.index].id
}


################################################################################
# Create Workload VMs
################################################################################
resource "azurerm_linux_virtual_machine" "workload_vm" {
  count               = var.workload_count
  name                = "${var.name_prefix}-workload-vm-${count.index + 1}-${var.resource_tag}"
  location            = var.location
  resource_group_name = var.resource_group

  network_interface_ids = [azurerm_network_interface.workload_nic[count.index].id]
  size                  = local.instance_size_selection
  admin_username        = var.server_admin_username
  computer_name         = "${var.name_prefix}-workload-${count.index + 1}-${var.resource_tag}"
  admin_ssh_key {
    username   = var.server_admin_username
    public_key = "${trimspace(var.ssh_key)} ${var.server_admin_username}@me.io"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = contains(local.unsupported_regions, lower(var.location)) ? "Standard_LRS" : "Premium_LRS"
  }

  source_image_reference {
    publisher = var.instance_image_publisher
    offer     = var.instance_image_offer
    sku       = var.instance_image_sku
    version   = var.instance_image_version
  }

  tags = var.global_tags

  depends_on = [
    azurerm_network_interface.workload_nic,
    azurerm_network_interface_security_group_association.workload_nic_association
  ]
}
