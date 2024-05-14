output "function_app_id" {
  description = "Function App ID"
  value       = azurerm_linux_function_app.vmss_orchestration_app.id
}

output "function_app_name" {
  description = "Function App ID"
  value       = "${var.name_prefix}-ccvmss-${var.resource_tag}-function-app"
}

output "function_app_outbound_ip_address_list" {
  description = "A list of outbound IP addresses used by the function"
  value       = azurerm_linux_function_app.vmss_orchestration_app.outbound_ip_address_list
}

output "manual_sync_exit_status" {
  description = "Exit status of the operation to manually sync the Azure Function App after deployment."
  value       = chomp(null_resource.contents.triggers["exitstatus"])
}

output "subscription_id" {
  description = "Subscription ID."
  value       = data.azurerm_subscription.current.subscription_id
}
