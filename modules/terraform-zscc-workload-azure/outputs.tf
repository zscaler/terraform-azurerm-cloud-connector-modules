output "private_ip" {
  description = "Instance Private IP Address"
  value       = azurerm_network_interface.workload_nic[*].private_ip_address
}
output "admin_username" {
  description = "Instance Admin Username"
  value       = azurerm_linux_virtual_machine.workload_vm[0].admin_username
}
