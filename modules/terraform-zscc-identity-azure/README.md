# Zscaler Cloud Connector / Azure Managed Identity Module

This module takes name and resource group inputs of an existing User Managed Identity resource as a data-source to generate an ID output used for Cloud Connector VM association.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.108.0, <= 3.116 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.108.0, <= 3.116 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_user_assigned_identity.function_app_identity_selected](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |
| [azurerm_user_assigned_identity.selected](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cc_vm_managed_identity_name"></a> [cc\_vm\_managed\_identity\_name](#input\_cc\_vm\_managed\_identity\_name) | Azure Managed Identity name to attach to the CC VM. E.g zspreview-66117-mi | `string` | n/a | yes |
| <a name="input_cc_vm_managed_identity_rg"></a> [cc\_vm\_managed\_identity\_rg](#input\_cc\_vm\_managed\_identity\_rg) | Resource Group of the Azure Managed Identity name to attach to the CC VM. E.g. edgeconnector\_rg\_1 | `string` | n/a | yes |
| <a name="input_function_app_managed_identity_name"></a> [function\_app\_managed\_identity\_name](#input\_function\_app\_managed\_identity\_name) | Azure Managed Identity name to attach to the Function App. E.g zspreview-66117-mi | `string` | `""` | no |
| <a name="input_function_app_managed_identity_rg"></a> [function\_app\_managed\_identity\_rg](#input\_function\_app\_managed\_identity\_rg) | Resource Group of the Azure Managed Identity name to attach to the Function App. E.g. edgeconnector\_rg\_1 | `string` | `""` | no |
| <a name="input_vmss_enabled"></a> [vmss\_enabled](#input\_vmss\_enabled) | Default is false non non-vmss deployments. If true, module will do a data lookup for an additional managed identity resource for Function App in the same subscription | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_app_managed_identity_client_id"></a> [function\_app\_managed\_identity\_client\_id](#output\_function\_app\_managed\_identity\_client\_id) | The Client ID of the User Assigned Identity dedicated for VMSS Function App |
| <a name="output_function_app_managed_identity_id"></a> [function\_app\_managed\_identity\_id](#output\_function\_app\_managed\_identity\_id) | User Managed Identity ID dedicated for VMSS Function App |
| <a name="output_function_app_managed_identity_principal_id"></a> [function\_app\_managed\_identity\_principal\_id](#output\_function\_app\_managed\_identity\_principal\_id) | The Object(Principal) ID of the User Assigned Identity dedicated for VMSS Function App |
| <a name="output_managed_identity_client_id"></a> [managed\_identity\_client\_id](#output\_managed\_identity\_client\_id) | The Client ID of the User Assigned Identity |
| <a name="output_managed_identity_id"></a> [managed\_identity\_id](#output\_managed\_identity\_id) | User Managed Identity ID |
| <a name="output_managed_identity_principal_id"></a> [managed\_identity\_principal\_id](#output\_managed\_identity\_principal\_id) | The Object(Principal) ID of the User Assigned Identity |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
