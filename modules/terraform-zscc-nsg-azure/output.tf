output "private_ip" {
  value = azurerm_network_interface.cc-mgmt-nic.*.private_ip_address
}

output "service_ip" {
  value = azurerm_network_interface.cc-service-nic.*.private_ip_address
}

output "cc_hostname" {
  value = azurerm_linux_virtual_machine.cc-vm.*.computer_name
}