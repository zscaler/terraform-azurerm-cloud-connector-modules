output "private_ip" {
  description = "Instance Private IP Address"
  value       = azurerm_network_interface.workload_nic[*].private_ip_address
}
