output "public_ip_address" {
  value = azurerm_windows_virtual_machine.cca-vdi.public_ip_address
}

output "admin_password" {
  value     = azurerm_windows_virtual_machine.cca-vdi.admin_password
}

output "admin_username" {
  value     = azurerm_windows_virtual_machine.cca-vdi.admin_username
}