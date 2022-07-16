output "private_ip" {
  value = azurerm_network_interface.server-nic.*.private_ip_address
}
