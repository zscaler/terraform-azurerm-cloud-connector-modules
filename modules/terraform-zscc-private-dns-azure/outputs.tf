output "private_dns_resolver_id" {
  description = "The ID of the Private DNS Resolver"
  value       = azurerm_private_dns_resolver.dns_resolver.id
}

output "private_dns_resolver_name" {
  description = "The name of the Private DNS Resolver"
  value       = azurerm_private_dns_resolver.dns_resolver.name
}

output "private_dns_outbound_endpoint_id" {
  description = "The ID of the Private DNS Resolver Outbound Endpoint"
  value       = azurerm_private_dns_resolver_outbound_endpoint.dns_outbound_endpoint.id
}

output "private_dns_outbound_endpoint_name" {
  description = "The name of the Private DNS Resolver Outbound Endpoint"
  value       = azurerm_private_dns_resolver_outbound_endpoint.dns_outbound_endpoint.name
}

output "private_dns_forwarding_ruleset_id" {
  description = "The ID of the Private DNS Resolver Dns Forwarding Ruleset. Use this if you want to link other Virtual Networks to this Ruleset"
  value       = azurerm_private_dns_resolver_dns_forwarding_ruleset.dns_forwarding_ruleset.id
}

output "private_dns_forwarding_ruleset_name" {
  description = "The name of the Private DNS Resolver Dns Forwarding Ruleset. Use this if you want to link other Virtual Networks to this Ruleset"
  value       = azurerm_private_dns_resolver_dns_forwarding_ruleset.dns_forwarding_ruleset.name
}
