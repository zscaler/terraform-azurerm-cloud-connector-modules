# Create NSG for CC Management interfaces
resource "azurerm_network_security_group" "cc-mgmt-nsg" {
  count               = var.byo_nsg == false ? var.nsg_count : 0
  name                = "${var.name_prefix}-cc-mgmt-nsg-${count.index + 1}-${var.resource_tag}"
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

# Or use existing Mgmt NSG
data "azurerm_network_security_group" "mgt-nsg-selected" {
  count               = var.byo_nsg == false ? length(azurerm_network_security_group.cc-mgmt-nsg.*.id) : length(var.byo_mgmt_nsg_names)
  name                = var.byo_nsg == false ? "${var.name_prefix}-cc-mgmt-nsg-${count.index + 1}-${var.resource_tag}" : element(var.byo_mgmt_nsg_names, count.index)
  resource_group_name = var.resource_group
}


# Create NSG for CC service interfaces
resource "azurerm_network_security_group" "cc-service-nsg" {
  count               = var.byo_nsg == false ? var.nsg_count : 0
  name                = "${var.name_prefix}-cc-service-nsg-${count.index + 1}-${var.resource_tag}"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "ALL_VNET"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
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

# Or use existing Service NSG
data "azurerm_network_security_group" "service-nsg-selected" {
  count               = var.byo_nsg == false ? length(azurerm_network_security_group.cc-service-nsg.*.id) : length(var.byo_mgmt_nsg_names)
  name                = var.byo_nsg == false ? "${var.name_prefix}-cc-service-nsg-${count.index + 1}-${var.resource_tag}" : element(var.byo_mgmt_nsg_names, count.index)
  resource_group_name = var.resource_group
}
