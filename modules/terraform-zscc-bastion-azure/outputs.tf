output "public_ip" {
  description = "Instance Public IP Address"
  value       = azurerm_public_ip.bastion_pip.ip_address
}
