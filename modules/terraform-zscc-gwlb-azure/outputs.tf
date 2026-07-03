output "gwlb_ip" {
  description = "Azure Gateway Load Balancer frontend private IP address"
  value       = azurerm_lb.cc_gwlb.frontend_ip_configuration[0].private_ip_address
}

output "gwlb_frontend_ip_config_id" {
  description = "Azure Gateway Load Balancer frontend IP configuration ID. Set this on the consumer Public Load Balancer frontend IP configuration to activate GWLB chaining"
  value       = azurerm_lb.cc_gwlb.frontend_ip_configuration[0].id
}

output "gwlb_backend_address_pool_id" {
  description = "Azure Gateway Load Balancer backend address pool ID. Used to associate CC VM NICs to the GWLB backend"
  value       = azurerm_lb_backend_address_pool.cc_gwlb_backend_pool.id
}

output "gwlb_probe_id" {
  description = "Azure Gateway Load Balancer health probe ID"
  value       = azurerm_lb_probe.cc_gwlb_probe.id
}

output "gwlb_rule_id" {
  description = "Azure Gateway Load Balancer load balancing rule ID"
  value       = azurerm_lb_rule.cc_gwlb_rule.id
}
