################################################################################
# Network Infrastructure Resources
################################################################################


################################################################################
# Resource Group
################################################################################
# Create Resource Group or reference existing
resource "azurerm_resource_group" "rg" {
  count    = var.byo_rg == false ? 1 : 0
  name     = "${var.name_prefix}-rg-${var.resource_tag}"
  location = var.location

  tags = var.global_tags
}

data "azurerm_resource_group" "rg_selected" {
  count = var.byo_rg ? 1 : 0
  name  = var.byo_rg_name
}


################################################################################
# Virtual Network
################################################################################
# Create Virtual Network or reference existing
resource "azurerm_virtual_network" "vnet" {
  count               = var.byo_vnet == false ? 1 : 0
  name                = "${var.name_prefix}-vnet-${var.resource_tag}"
  address_space       = [var.network_address_space]
  location            = var.location
  resource_group_name = try(data.azurerm_resource_group.rg_selected[0].name, azurerm_resource_group.rg[0].name)

  tags = var.global_tags
}

data "azurerm_virtual_network" "vnet_selected" {
  count               = var.byo_vnet ? 1 : 0
  name                = var.byo_vnet_name
  resource_group_name = var.byo_vnet_subnets_rg_name
}


################################################################################
# Virtual Network connection to VWAN Hub
################################################################################
locals {
  virtual_hub_name = var.vwan_hub_id != null && var.vwan_hub_id != "" ? element(split("/", var.vwan_hub_id), length(split("/", var.vwan_hub_id)) - 1) : null
}

# Create VNET to VWAN Connection or reference existing
resource "azurerm_virtual_hub_connection" "vnet_to_vwan" {
  count                     = var.vwan_hub_id != null && var.vwan_hub_id != "" && (var.vnet_connection_name == null || var.vnet_connection_name == "") ? 1 : 0
  name                      = "${var.name_prefix}-vnet-vwan-connection-${var.resource_tag}"
  virtual_hub_id            = var.vwan_hub_id
  remote_virtual_network_id = var.byo_vnet ? data.azurerm_virtual_network.vnet_selected[0].id : azurerm_virtual_network.vnet[0].id
}

data "azurerm_virtual_hub_connection" "vnet_to_vwan_selected" {
  count               = var.vwan_hub_id != null && var.vwan_hub_id != "" && var.vnet_connection_name != null && var.vnet_connection_name != "" ? 1 : 0
  name                = var.vwan_hub_id != null && var.vwan_hub_id != "" && var.vnet_connection_name != null && var.vnet_connection_name != "" ? var.vnet_connection_name : azurerm_virtual_hub_connection.vnet_to_vwan[0].name
  resource_group_name = try(data.azurerm_resource_group.rg_selected[0].name, azurerm_resource_group.rg[0].name)
  virtual_hub_name    = local.virtual_hub_name
}

################################################################################
# NAT Gateway
################################################################################
# Create Public IP for NAT Gateway or reference existing
resource "azurerm_public_ip" "pip" {
  count                   = var.byo_pips == false && var.base_only == false ? length(distinct(var.zones)) : 0
  name                    = "${var.name_prefix}-public-ip-${count.index + 1}-${var.resource_tag}"
  location                = var.location
  resource_group_name     = try(data.azurerm_resource_group.rg_selected[0].name, azurerm_resource_group.rg[0].name)
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 30
  zones                   = local.zones_supported ? [element(var.zones, count.index)] : null

  tags = var.global_tags

  lifecycle {
    ignore_changes = [ip_tags]
  }
}

data "azurerm_public_ip" "pip_selected" {
  count               = var.byo_pips ? length(var.byo_pip_names) : 0
  name                = element(var.byo_pip_names, count.index)
  resource_group_name = var.byo_pip_rg
}


# Create NAT Gateway or reference an existing
resource "azurerm_nat_gateway" "ngw" {
  count                   = var.byo_nat_gws == false && var.base_only == false ? length(distinct(var.zones)) : 0
  name                    = "${var.name_prefix}-ngw-${count.index + 1}-${var.resource_tag}"
  location                = var.location
  resource_group_name     = try(data.azurerm_resource_group.rg_selected[0].name, azurerm_resource_group.rg[0].name)
  idle_timeout_in_minutes = 10
  zones                   = local.zones_supported ? [element(var.zones, count.index)] : null

  tags = var.global_tags
}

data "azurerm_nat_gateway" "ngw_selected" {
  count               = var.byo_nat_gws ? length(var.byo_nat_gw_names) : 0
  name                = element(var.byo_nat_gw_names, count.index)
  resource_group_name = var.byo_nat_gw_rg
}

# Associate Public IP to NAT Gateway
locals {
  ngw_associations_selected = var.byo_nat_gws ? data.azurerm_nat_gateway.ngw_selected[*].id : azurerm_nat_gateway.ngw[*].id
}

resource "azurerm_nat_gateway_public_ip_association" "ngw_association" {
  count                = var.existing_nat_gw_pip_association ? 0 : length(local.ngw_associations_selected)
  nat_gateway_id       = try(data.azurerm_nat_gateway.ngw_selected[count.index].id, azurerm_nat_gateway.ngw[count.index].id)
  public_ip_address_id = try(data.azurerm_public_ip.pip_selected[count.index].id, azurerm_public_ip.pip[count.index].id)
}


################################################################################
# Private (Cloud Connector) Subnets
################################################################################
# Create Cloud Connector Subnet
resource "azurerm_subnet" "cc_subnet" {
  count                = var.byo_subnets == false && var.base_only == false ? length(distinct(var.zones)) : 0
  name                 = "${var.name_prefix}-cc-subnet-${count.index + 1}-${var.resource_tag}"
  resource_group_name  = var.byo_vnet == false ? try(data.azurerm_virtual_network.vnet_selected[0].resource_group_name, azurerm_virtual_network.vnet[0].resource_group_name) : var.byo_vnet_subnets_rg_name
  virtual_network_name = var.byo_vnet == false ? try(data.azurerm_virtual_network.vnet_selected[0].name, azurerm_virtual_network.vnet[0].name) : var.byo_vnet_name
  address_prefixes     = var.cc_subnets != null ? [element(var.cc_subnets, count.index)] : [cidrsubnet(var.network_address_space, 8, count.index + 200)]
}

# Or reference an existing subnet
data "azurerm_subnet" "cc_subnet_selected" {
  count                = var.byo_subnets == false ? length(azurerm_subnet.cc_subnet[*].id) : length(var.byo_subnet_names)
  name                 = var.byo_subnets == false ? azurerm_subnet.cc_subnet[count.index].name : element(var.byo_subnet_names, count.index)
  resource_group_name  = var.byo_vnet == false ? try(data.azurerm_virtual_network.vnet_selected[0].resource_group_name, azurerm_virtual_network.vnet[0].resource_group_name) : var.byo_vnet_subnets_rg_name
  virtual_network_name = var.byo_vnet == false ? try(data.azurerm_virtual_network.vnet_selected[0].name, azurerm_virtual_network.vnet[0].name) : var.byo_vnet_name
}

# Associate Cloud Connector Subnet to NAT Gateway
resource "azurerm_subnet_nat_gateway_association" "cc_subnet_nat_association" {
  count          = var.existing_nat_gw_subnet_association == false ? length(data.azurerm_subnet.cc_subnet_selected[*].id) : 0
  subnet_id      = data.azurerm_subnet.cc_subnet_selected[count.index].id
  nat_gateway_id = try(data.azurerm_nat_gateway.ngw_selected[count.index].id, azurerm_nat_gateway.ngw[count.index].id)

  depends_on = [
    data.azurerm_subnet.cc_subnet_selected,
  ]
}


################################################################################
# Private (Workload) Subnet and Route Table
################################################################################
# Create Workload Subnet
resource "azurerm_subnet" "workload_subnet" {
  count                = var.workloads_enabled == true ? 1 : 0
  name                 = "${var.name_prefix}-workload-subnet-${var.resource_tag}"
  resource_group_name  = try(data.azurerm_resource_group.rg_selected[0].name, azurerm_resource_group.rg[0].name)
  virtual_network_name = try(data.azurerm_virtual_network.vnet_selected[0].name, azurerm_virtual_network.vnet[0].name)
  address_prefixes     = var.workloads_subnets != null ? [element(var.workloads_subnets, count.index)] : [cidrsubnet(var.network_address_space, 8, count.index + 1)]
}

# Create Workload Route Table to send to Cloud Connector
resource "azurerm_route_table" "workload_rt" {
  count               = var.workloads_enabled == true ? 1 : 0
  name                = "${var.name_prefix}-workload-rt-${var.resource_tag}"
  location            = var.location
  resource_group_name = try(data.azurerm_resource_group.rg_selected[0].name, azurerm_resource_group.rg[0].name)

  bgp_route_propagation_enabled = false

  route {
    name                   = "default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = var.base_only == true ? "Internet" : "VirtualAppliance"
    next_hop_in_ip_address = var.lb_enabled == true ? var.lb_frontend_ip : element(var.cc_service_ip, count.index)
  }
}

# Associate Route Table with Workload Subnet
resource "azurerm_subnet_route_table_association" "workload_rt_association" {
  count          = length(azurerm_route_table.workload_rt[*].id)
  subnet_id      = azurerm_subnet.workload_subnet[count.index].id
  route_table_id = azurerm_route_table.workload_rt[count.index].id
}


################################################################################
# Public (Bastion) Subnets
################################################################################
# Create Bastion Host public subnet
resource "azurerm_subnet" "bastion_subnet" {
  count                = var.bastion_enabled == true ? 1 : 0
  name                 = "${var.name_prefix}-bastion-subnet-${var.resource_tag}"
  resource_group_name  = try(data.azurerm_resource_group.rg_selected[0].name, azurerm_resource_group.rg[0].name)
  virtual_network_name = try(data.azurerm_virtual_network.vnet_selected[0].name, azurerm_virtual_network.vnet[0].name)
  address_prefixes     = var.public_subnets != null ? [element(var.public_subnets, count.index)] : [cidrsubnet(var.network_address_space, 8, 101)]
}


################################################################################
# Outbound Private DNS Subnet and Route Table
################################################################################
# Create private subnet for outbound private DNS and delegate to dnsResolvers service
resource "azurerm_subnet" "private_dns_subnet" {
  count                = var.zpa_enabled ? 1 : 0
  name                 = "${var.name_prefix}-outbound-dns-subnet-${var.resource_tag}"
  resource_group_name  = try(data.azurerm_resource_group.rg_selected[0].name, azurerm_resource_group.rg[0].name)
  virtual_network_name = try(data.azurerm_virtual_network.vnet_selected[0].name, azurerm_virtual_network.vnet[0].name)
  address_prefixes     = var.private_dns_subnet != null ? [var.private_dns_subnet] : [cidrsubnet(var.network_address_space, 12, 2480)]

  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }
}

# Create Outbound DNS Route Table to send to Cloud Connector
resource "azurerm_route_table" "private_dns_rt" {
  count               = var.zpa_enabled ? 1 : 0
  name                = "${var.name_prefix}-outbound-dns-rt-${var.resource_tag}"
  location            = var.location
  resource_group_name = try(data.azurerm_resource_group.rg_selected[0].name, azurerm_resource_group.rg[0].name)

  bgp_route_propagation_enabled = false

  route {
    name                   = "default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.lb_enabled == true ? var.lb_frontend_ip : element(var.cc_service_ip, count.index)
  }
}

# Associate Route Table with Outbound DNS Subnet
resource "azurerm_subnet_route_table_association" "private_dns_rt_association" {
  count          = length(azurerm_route_table.private_dns_rt[*].id)
  subnet_id      = azurerm_subnet.private_dns_subnet[count.index].id
  route_table_id = azurerm_route_table.private_dns_rt[count.index].id
}
