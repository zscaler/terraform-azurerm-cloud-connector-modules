output "private_ip" {
  description = "Instance Management Interface Private IP Address"
  value       = azurerm_network_interface.cc_mgmt_nic[*].private_ip_address
}

output "service_ip" {
  description = "Instance Service Interface Private IP Address"
  value       = azurerm_network_interface.cc_service_nic[*].private_ip_address
}

output "cc_hostname" {
  description = "Instance Host Name"
  value       = azurerm_linux_virtual_machine.cc_vm[*].computer_name
}
