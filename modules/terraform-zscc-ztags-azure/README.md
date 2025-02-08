# Zscaler Cloud Connector / ZTags (Event Grid System Topic) Module

This module is used to automate the creation of a new Global Subscription based Event Grid System Topic and Event Subscription targeting a user provided PartnerDestination endpoint in a new or existing Resource Group. This enables Zscaler to send and receive event notifications for new resource add/delete/change operations for a designated source Subscription.

## Assumptions

* The account running this Terraform module has the ability to install both AzureRM and AzAPI providers.
* The account running this Terraform module has the permissions to create required Event Grid resources defined below.
* This module depends on an existing Azure Account and Permissions added for Zscaler Azure Tag Discovery Service enablement. After enabling via the Zscaler Cloud Connector Portal, you will be provided a full PartnerDestination resource ID. Copy this string and use for variable partnerdestination_id.

## Caveats

* There is an Azure constraint where only one System Topic of type: Microsoft.ResourceNotifications.Resources can exist per scoped Subscription. If you try deploying to a Subscription that already consists of such a System Topic, Azure API will fail with a response like:

 RESPONSE 400: 400 Bad Request
│ ERROR CODE: InvalidRequest
│ --------------------------------------------------------------------------------
│ {
│   "error": {
│     "code": "InvalidRequest",
│     "message": "There is an existing tracked system topic for the given source /subscriptions/'subscription id'. Only one system topic is allowed per source."
│   }
│ }

* Ensure that the account executing Terraform has necessary permissions to create the System Topic. The recommendation is Contributor RBAC scoped at the Subscription due to the Global System Topic resource dependency.

RESPONSE 400: 400 Bad Request
│ ERROR CODE: InvalidRequest
│ --------------------------------------------------------------------------------
│ {
│   "error": {
│     "code": "InvalidRequest",
│     "message": "The user does not have permission to perform the operation on the resource /subscriptions/51bfd9a7-5de6-4903-97e7-73a56691caa0."
│   }
│ }
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.108.0, <= 3.116 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.108.0, <= 3.116 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.zs_event_subscription](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.zs_system_topic](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_resource_group.zs_tags_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.existing_zs_tags_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.current_subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Populate any custom user defined tags from a map | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region to create Resource Group for Zscaler Event Grid System Topic (Not required if using an existing resource group via var.resource\_group) | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the workload module resources | `string` | `null` | no |
| <a name="input_partnerdestination_id"></a> [partnerdestination\_id](#input\_partnerdestination\_id) | Zscaler registered PartnerDestination ID. example: /subscriptions/<subscriptionId>/resourceGroups/<partnerResourceGroup/providers/Microsoft.EventGrid/partnerDestinations/<partnerDestinationName> | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing Resource Group Name | `string` | `null` | no |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the workload module resources | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Optional) Azure Subscription ID for Event Grid System Topic source property. If none specified, resource will use caller subscription id | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ztags_event_grid_system_topic_id"></a> [ztags\_event\_grid\_system\_topic\_id](#output\_ztags\_event\_grid\_system\_topic\_id) | Event Grid System Topic ID for Zscaler Tagging Service |
| <a name="output_ztags_event_grid_system_topic_name"></a> [ztags\_event\_grid\_system\_topic\_name](#output\_ztags\_event\_grid\_system\_topic\_name) | Event Grid System Topic Name for Zscaler Tagging Service |
| <a name="output_ztags_resource_group_id"></a> [ztags\_resource\_group\_id](#output\_ztags\_resource\_group\_id) | Event Grid System Topic Resource Group Name |
| <a name="output_ztags_resource_group_name"></a> [ztags\_resource\_group\_name](#output\_ztags\_resource\_group\_name) | Event Grid System Topic Resource Group Name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
