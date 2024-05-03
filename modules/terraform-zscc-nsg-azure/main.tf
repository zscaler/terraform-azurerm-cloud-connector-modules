################################################################################
# Create NSG and Rules for CC Management interfaces
################################################################################
resource "azurerm_network_security_group" "cc_mgmt_nsg" {
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

  dynamic "security_rule" {
    for_each = var.support_access_enabled ? ["1"] : []

    content {
      name                       = "Zscaler_Support_Access"
      description                = "Required for Cloud Connector to establish connectivity for Zscaler Support to remotely assist"
      priority                   = 3000
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "12002"
      source_address_prefix      = "*"
      destination_address_prefix = var.zssupport_server
    }
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
data "azurerm_network_security_group" "mgt_nsg_selected" {
  count               = var.byo_nsg ? length(var.byo_mgmt_nsg_names) : 0
  name                = var.byo_nsg ? element(var.byo_mgmt_nsg_names, count.index) : 0
  resource_group_name = var.resource_group
}


################################################################################
# Create NSG and Rules for CC Service interfaces
################################################################################
resource "azurerm_network_security_group" "cc_service_nsg" {
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
data "azurerm_network_security_group" "service_nsg_selected" {
  count               = var.byo_nsg ? length(var.byo_service_nsg_names) : 0
  name                = var.byo_nsg ? element(var.byo_service_nsg_names, count.index) : 0
  resource_group_name = var.resource_group
}
