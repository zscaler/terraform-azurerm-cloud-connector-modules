output "public_ip" {
  value = azurerm_public_ip.bastion-pip.ip_address
}
