output "vmss_names" {
  description = "VMSS Names"
  value       = azurerm_orchestrated_virtual_machine_scale_set.cc_vmss[*].name
}

output "vmss_ids" {
  description = "VMSS IDs"
  value       = azurerm_orchestrated_virtual_machine_scale_set.cc_vmss[*].id
}
