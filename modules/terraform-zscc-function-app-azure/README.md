# Zscaler Cloud Connector VMSS / Azure Function App Module

This module provides the necessary resource creation and configuration parameters to deploy the Zscaler generated Azure Function App and dependencies required for management and health monitoring of Cloud Connectors deployed in a Virtual Machine Scale Set (VMSS). Recommended configuration includes the creation of a new Azure Storage Account for Function App zip file upload/storage and runtime. For full functionality, a dedicate App Service Plan and Application Insights resource are required for custom metric ingestion and processing.

| Function ZIP Version | SHA256 Hash | GitHub Release Date/Tag |
| ----------- | --------| ------------ |
| 1.0.1*| aed981cf32c7cf62623f3195b8e1315afb570b43d451a0ba0e782e4ba0d828dd | 12/06/2024 - [v0.6.2](https://github.com/zscaler/terraform-azurerm-cloud-connector-modules/releases/tag/v0.6.2) |
| 1.0.0 | 8de1144256df20f970f9c382c001bad14d2de1407a9d8b7a6edd3a6c5143d3bc | 09/05/2024 - [v0.6.0](https://github.com/zscaler/terraform-azurerm-cloud-connector-modules/releases/tag/v0.6.0) |

*Zscaler recommends always running the latest Function App ZIP Version

## Caveats/Considerations
Azure Function App is deployed with App Service Plan as its [hosting option](https://learn.microsoft.com/en-us/azure/azure-functions/functions-scale). The recommended hosting option is Flex Consumption Plan (SKU Name: Y1), but there are some limitations with this.

1. Recommended Flex Consumption plan and/or Consumption plan is not available for use in all Azure Regions. See [Product Availability by Region](https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/table) and search for Functions.
2. Only Flex Consumption supports [Virtual Network Integration](https://learn.microsoft.com/en-us/azure/azure-functions/functions-networking-options?tabs=azure-portal#virtual-network-integration). If this plan is not available in your region, and you require VNet Integration, you will need to upgrade to Elastic Premium (EP1) plan.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.108.0, <= 3.116 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.108.0, <= 3.116 |
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.vmss_orchestration_app_insights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_linux_function_app.vmss_orchestration_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_linux_function_app.vmss_orchestration_app_with_manual_sync](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_log_analytics_workspace.vmss_orchestration_log_analytics_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_service_plan.vmss_orchestration_app_service_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.cc_function_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_blob.cc_function_storage_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |
| [azurerm_storage_container.cc_function_storage_container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_account.existing_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [local_file.manual_sync_exist_status](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asp_sku_name"></a> [asp\_sku\_name](#input\_asp\_sku\_name) | SKU Name for the App Service Plan. Recommended Y1 (flex consumption) for function app unless not supported by Azure region | `string` | `"Y1"` | no |
| <a name="input_azure_vault_url"></a> [azure\_vault\_url](#input\_azure\_vault\_url) | Azure Vault URL | `string` | n/a | yes |
| <a name="input_cc_vm_prov_url"></a> [cc\_vm\_prov\_url](#input\_cc\_vm\_prov\_url) | Zscaler Cloud Connector Provisioning URL | `string` | n/a | yes |
| <a name="input_existing_log_analytics_workspace"></a> [existing\_log\_analytics\_workspace](#input\_existing\_log\_analytics\_workspace) | Set to True if you wish to use an existing Log Analytics Workspace to associate with the AppInsights Instance. Default is false meaning Terraform module will create a new one | `bool` | `false` | no |
| <a name="input_existing_log_analytics_workspace_id"></a> [existing\_log\_analytics\_workspace\_id](#input\_existing\_log\_analytics\_workspace\_id) | ID of existing Log Analytics Workspace to associate with the AppInsights Instance. | `string` | `""` | no |
| <a name="input_existing_storage_account"></a> [existing\_storage\_account](#input\_existing\_storage\_account) | Set to True if you wish to use an existing Storage Account to associate with the Function App. Default is false meaning Terraform module will create a new one | `bool` | `false` | no |
| <a name="input_existing_storage_account_name"></a> [existing\_storage\_account\_name](#input\_existing\_storage\_account\_name) | Name of existing Storage Account to associate with the Function App. | `string` | `""` | no |
| <a name="input_existing_storage_account_rg"></a> [existing\_storage\_account\_rg](#input\_existing\_storage\_account\_rg) | Resource Group of existing Storage Account to associate with the Function App. | `string` | `""` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Populate any custom user defined tags from a map | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Cloud Connector Azure Region | `string` | n/a | yes |
| <a name="input_log_analytics_retention_days"></a> [log\_analytics\_retention\_days](#input\_log\_analytics\_retention\_days) | Log Analytics Workspace retention time in days. | `number` | `30` | no |
| <a name="input_log_analytics_sku"></a> [log\_analytics\_sku](#input\_log\_analytics\_sku) | Log Analytics Workspace SKU | `string` | `"PerGB2018"` | no |
| <a name="input_managed_identity_client_id"></a> [managed\_identity\_client\_id](#input\_managed\_identity\_client\_id) | Client ID of the User Managed Identity for Function App to utilize | `string` | n/a | yes |
| <a name="input_managed_identity_id"></a> [managed\_identity\_id](#input\_managed\_identity\_id) | ID of the User Managed Identity assigned to Function App | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the CC VM module resources | `string` | `null` | no |
| <a name="input_path_to_scripts"></a> [path\_to\_scripts](#input\_path\_to\_scripts) | Path to script\_directory | `string` | `""` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Main Resource Group Name | `string` | n/a | yes |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the CC VM module resources | `string` | `null` | no |
| <a name="input_run_manual_sync"></a> [run\_manual\_sync](#input\_run\_manual\_sync) | Set to True if you would like terraform to run the manual sync operation to start the Function App after creation. The alternative is to navigate to the Function App on the Azure Portal UI or to manually invoke the script yourself. | `bool` | `true` | no |
| <a name="input_terminate_unhealthy_instances"></a> [terminate\_unhealthy\_instances](#input\_terminate\_unhealthy\_instances) | Indicate whether detected unhealthy instances are terminated or not. | `bool` | `true` | no |
| <a name="input_upload_function_app_zip"></a> [upload\_function\_app\_zip](#input\_upload\_function\_app\_zip) | By default, this Terraform will create a new Storage Account/Container/Blob to upload the zip file. The function app will pull from the blobl url to run. Setting this value to false will prevent creation/upload of the blob file | `bool` | `true` | no |
| <a name="input_vmss_names"></a> [vmss\_names](#input\_vmss\_names) | Names of Virtual Machine Scale Sets for Function App to monitor provided as a list | `list(string)` | n/a | yes |
| <a name="input_zscaler_cc_function_public_url"></a> [zscaler\_cc\_function\_public\_url](#input\_zscaler\_cc\_function\_public\_url) | Publicly accessible URL path where Function App can pull its zip file build from. This is only required when var.upload\_function\_app\_zip is set to false | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_app_id"></a> [function\_app\_id](#output\_function\_app\_id) | Function App ID |
| <a name="output_function_app_name"></a> [function\_app\_name](#output\_function\_app\_name) | Function App ID |
| <a name="output_function_app_outbound_ip_address_list"></a> [function\_app\_outbound\_ip\_address\_list](#output\_function\_app\_outbound\_ip\_address\_list) | A list of outbound IP addresses used by the function |
| <a name="output_manual_sync_exit_status"></a> [manual\_sync\_exit\_status](#output\_manual\_sync\_exit\_status) | Exit status of the operation to manually sync the Azure Function App after deployment. |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | Subscription ID. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
