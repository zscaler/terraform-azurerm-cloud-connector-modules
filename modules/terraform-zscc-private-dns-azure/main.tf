################################################################################
# Create Azure Private DNS Resolver
################################################################################
resource "azurerm_private_dns_resolver" "dns_resolver" {
  name                = "${var.name_prefix}-${var.location}-dns-resolver-${var.resource_tag}"
  resource_group_name = var.resource_group
  location            = var.location
  virtual_network_id  = var.vnet_id

  tags = var.global_tags
}


################################################################################
# Create Azure Private DNS Resolver Outbound Endpoint
################################################################################
resource "azurerm_private_dns_resolver_outbound_endpoint" "dns_outbound_endpoint" {
  name                    = "${var.name_prefix}-outbound-endpoint-${var.resource_tag}"
  private_dns_resolver_id = azurerm_private_dns_resolver.dns_resolver.id
  location                = var.location
  subnet_id               = var.private_dns_subnet_id

  tags = var.global_tags
}


################################################################################
# Create Azure Private DNS Resolver Forwarding Ruleset
################################################################################
resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "dns_forwarding_ruleset" {
  name                                       = "${var.name_prefix}-fwd-ruleset-${var.resource_tag}"
  resource_group_name                        = var.resource_group
  location                                   = var.location
  private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.dns_outbound_endpoint.id]

  tags = var.global_tags
}


################################################################################
# Create Azure Private DNS Resolver Forwarding Rules
################################################################################
resource "azurerm_private_dns_resolver_forwarding_rule" "dns_forwarding_rule" {
  for_each                  = var.domain_names
  name                      = "${var.name_prefix}-fwd-rule-${each.key}-${var.resource_tag}"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.dns_forwarding_ruleset.id
  domain_name               = each.value
  enabled                   = true

  dynamic "target_dns_servers" {
    for_each = var.target_address

    content {
      ip_address = target_dns_servers.value
      port       = 53
    }
  }
}
