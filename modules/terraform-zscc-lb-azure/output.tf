output "lb_ip" {
  value = azurerm_lb.cc-lb.private_ip_address
}

output "lb_backend_address_pool" {
  value = azurerm_lb_backend_address_pool.cc-lb-backend-pool.id
}