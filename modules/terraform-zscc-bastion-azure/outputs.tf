output "public_ip" {
  description = "Instance Public IP Address"
  value       = azurerm_public_ip.bastion_pip.ip_address
}

output "admin_username" {
  description = "Instance Admin Username"
  value       = azurerm_linux_virtual_machine.bastion_vm.admin_username
}
