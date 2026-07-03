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

  dynamic "security_rule" {
    for_each = var.public_lb_deployed ? ["1"] : []
    content {
      name                       = "AllowHTTP"
      priority                   = 4010
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  dynamic "security_rule" {
    for_each = var.public_lb_deployed ? ["1"] : []
    content {
      name                       = "AllowHTTPS"
      priority                   = 4015
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
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

################################################################################
# Create NSG specifically for the service interface in Gateway Load Balancer
# (GWLB) deployments. Naming follows the cc_*_nsg pattern of the mgmt and
# service NSGs above.
#
# Security note: VXLAN traffic is sourced exclusively from the Azure GWLB data
# plane (service tag "AzureLoadBalancer"). Allowing UDP from "*" would permit
# arbitrary UDP from the internet. The two rules below restrict inbound VXLAN
# to the AzureLoadBalancer service tag and only to the configured VXLAN port
# range (vxlan_internal_port – vxlan_external_port), then deny everything else.
################################################################################
resource "azurerm_network_security_group" "cc_service_gwlb_nsg" {
  count               = var.gwlb_enabled ? 1 : 0
  name                = "${var.name_prefix}-cc-service-gwlb-nsg-${var.resource_tag}"
  location            = var.location
  resource_group_name = var.resource_group

  # Allow VXLAN UDP from the Azure GWLB data plane only.
  # Source is restricted to the AzureLoadBalancer service tag so that arbitrary
  # internet hosts cannot send UDP to the CC service NIC.
  # Destination port range covers both the internal and external VXLAN ports
  # (e.g. 10800-10801 by default). Adjust var.vxlan_internal_port /
  # var.vxlan_external_port if you use non-default ports.
  security_rule {
    name                       = "VXLAN-Allow-GWLB"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "${var.vxlan_internal_port}-${var.vxlan_external_port}"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  # Deny all other inbound UDP/TCP that was not matched above.
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "OUTBOUND-Allow"
    priority                   = 200
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
