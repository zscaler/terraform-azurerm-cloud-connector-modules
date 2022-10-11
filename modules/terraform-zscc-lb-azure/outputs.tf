output "lb_ip" {
  description = "Azure Load Balancer Frontend IP"
  value       = azurerm_lb.cc_lb.private_ip_address
}

output "lb_backend_address_pool" {
  description = "Azure Load Balancer Backend Pool ID"
  value       = azurerm_lb_backend_address_pool.cc_lb_backend_pool.id
}
