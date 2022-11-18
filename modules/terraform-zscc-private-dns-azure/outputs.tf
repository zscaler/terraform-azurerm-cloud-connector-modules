output "outbound_endpoint_id" {
  description = "Azure DNS Private Resolver Outbound Endpoint ID"
  value       = azurerm_private_dns_resolver_outbound_endpoint.dns_outbound_endpoint.id
}
