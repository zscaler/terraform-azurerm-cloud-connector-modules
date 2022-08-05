output "private_ip" {
  value = azurerm_network_interface.workload-nic.*.private_ip_address
}
