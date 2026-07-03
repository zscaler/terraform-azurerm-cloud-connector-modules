output "lb_ip" {
  description = "Azure Public Load Balancer Frontend IP"
  value       = azurerm_public_ip.frontend_ip.ip_address
}

output "lb_backend_address_pool" {
  description = "Azure Public Load Balancer Backend Pool ID"
  value       = azurerm_lb_backend_address_pool.cc_lb_backend_pool.id
}
