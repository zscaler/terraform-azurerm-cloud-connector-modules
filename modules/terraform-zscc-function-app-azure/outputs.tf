output "function_app_id" {
  description = "Function App ID"
  value       = azurerm_linux_function_app.vmss_orchestration_app.id
}

output "function_app_outbound_ip_address_list" {
  description = "A list of outbound IP addresses used by the function"
  value       = azurerm_linux_function_app.vmss_orchestration_app.outbound_ip_address_list
}
