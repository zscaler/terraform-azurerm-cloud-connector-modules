# Zscaler Cloud Connector / Azure Virtual Machine Scale Sets (VMSS) Module

This module provides all required configuration parameters to create a flexible orchestration Virtual Machine Scale Set (VMSS) and scaling policies for Zscaler Cloud Connector deployment.

## Accept Azure Marketplace Terms

Accept the Cloud Connector VM image terms for the Subscription(s) where Cloud Connector is to be deployed. This can be done via the Azure Portal, Cloud Shell or az cli / powershell with a valid admin user/service principal:

```sh
az vm image terms accept --urn zscaler1579058425289:zia_cloud_connector:zs_ser_gen1_cc_01:latest
```

| Azure Cloud      | Publisher ID         | Offer/Product ID        | SKU/Plan ID       | Version                              |
|:----------------:|:--------------------:|:-----------------------:|:-----------------:|:------------------------------------:|
| public (default) | zscaler1579058425289 | zia_cloud_connector     | zs_ser_gen1_cc_01 | 24.3.2 (Latest - as of Sep, 2024) |
| usgovernment     | zscaler1579058425289 | zia_cloud_connector     | zs_ser_gen1_cc_01 | 24.3.2 (Latest - as of Sep, 2024) |
| china            | cbcnetworks          | zscaler-cloud-connector | zs_ser_gen1_cc_01 | 24.3.2 (Latest - as of Sep, 2024) |

## Considerations
* DO NOT modify the NIC ordering per this reference module for deployments. Cloud Connector explicitly requires that the ordering of network_interface_ids associated to the azurerm_linux_virtual_machine are #1/first "Management". Any number of "Service" interfaces associated are read sequentially thereafter. Cloud Connector associates the first interface with its management services. The "Service" interfaces require IP_Forwarding enabled for traffic processing which is not enabled on the "Management" interface.



<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.9.0, < 5.0.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.9.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_autoscale_setting.vmss_autoscale_setting](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |
| [azurerm_orchestrated_virtual_machine_scale_set.cc_vmss](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/orchestrated_virtual_machine_scale_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerated_networking_enabled"></a> [accelerated\_networking\_enabled](#input\_accelerated\_networking\_enabled) | Enable/Disable accelerated networking support on all Cloud Connector service interfaces | `bool` | `true` | no |
| <a name="input_backend_address_pool"></a> [backend\_address\_pool](#input\_backend\_address\_pool) | Azure LB Backend Address Pool ID for NIC association | `string` | `null` | no |
| <a name="input_cc_username"></a> [cc\_username](#input\_cc\_username) | Default Cloud Connector admin/root username | `string` | `"zsroot"` | no |
| <a name="input_ccvm_image_offer"></a> [ccvm\_image\_offer](#input\_ccvm\_image\_offer) | Azure Marketplace Cloud Connector Image Offer | `string` | `"zia_cloud_connector"` | no |
| <a name="input_ccvm_image_publisher"></a> [ccvm\_image\_publisher](#input\_ccvm\_image\_publisher) | Azure Marketplace Cloud Connector Image Publisher | `string` | `"zscaler1579058425289"` | no |
| <a name="input_ccvm_image_sku"></a> [ccvm\_image\_sku](#input\_ccvm\_image\_sku) | Azure Marketplace Cloud Connector Image SKU | `string` | `"zs_ser_gen1_cc_01"` | no |
| <a name="input_ccvm_image_version"></a> [ccvm\_image\_version](#input\_ccvm\_image\_version) | Azure Marketplace Cloud Connector Image Version | `string` | `"latest"` | no |
| <a name="input_ccvm_instance_type"></a> [ccvm\_instance\_type](#input\_ccvm\_instance\_type) | Cloud Connector Image size | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_ccvm_source_image_id"></a> [ccvm\_source\_image\_id](#input\_ccvm\_source\_image\_id) | Custom Cloud Connector Source Image ID. Set this value to the path of a local subscription Microsoft.Compute image to override the Cloud Connector deployment instead of using the marketplace publisher | `string` | `null` | no |
| <a name="input_encryption_at_host_enabled"></a> [encryption\_at\_host\_enabled](#input\_encryption\_at\_host\_enabled) | User input for enabling or disabling host encryption | `bool` | `true` | no |
| <a name="input_fault_domain_count"></a> [fault\_domain\_count](#input\_fault\_domain\_count) | platformFaultDomainCount must be set to 1 for max spreading or 5 for static fixed spreading. Fixed spreading with 2 or 3 fault domains isn't supported for zonal deployments | `number` | `1` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Populate any custom user defined tags from a map | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Cloud Connector Azure Region | `string` | n/a | yes |
| <a name="input_managed_identity_id"></a> [managed\_identity\_id](#input\_managed\_identity\_id) | ID of the User Managed Identity assigned to Cloud Connector VM | `string` | n/a | yes |
| <a name="input_mgmt_nsg_id"></a> [mgmt\_nsg\_id](#input\_mgmt\_nsg\_id) | Cloud Connector management interface nsg id | `string` | n/a | yes |
| <a name="input_mgmt_subnet_id"></a> [mgmt\_subnet\_id](#input\_mgmt\_subnet\_id) | Cloud Connector management subnet id. | `list(string)` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the CC VM module resources | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Main Resource Group Name | `string` | n/a | yes |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the CC VM module resources | `string` | `null` | no |
| <a name="input_scale_in_cooldown"></a> [scale\_in\_cooldown](#input\_scale\_in\_cooldown) | Amount of time after scale in before scale in is evaluated again. | `string` | `"PT15M"` | no |
| <a name="input_scale_in_count"></a> [scale\_in\_count](#input\_scale\_in\_count) | Number of CCs to bring up on scale in event. | `string` | `"1"` | no |
| <a name="input_scale_in_evaluation_period"></a> [scale\_in\_evaluation\_period](#input\_scale\_in\_evaluation\_period) | Amount of time the average of scaling metric is evaluated over. | `string` | `"PT5M"` | no |
| <a name="input_scale_in_threshold"></a> [scale\_in\_threshold](#input\_scale\_in\_threshold) | Metric threshold for determining scale in. | `number` | `50` | no |
| <a name="input_scale_out_cooldown"></a> [scale\_out\_cooldown](#input\_scale\_out\_cooldown) | Amount of time after scale out before scale out is evaluated again. | `string` | `"PT15M"` | no |
| <a name="input_scale_out_count"></a> [scale\_out\_count](#input\_scale\_out\_count) | Number of CCs to bring up on scale out event. | `string` | `"1"` | no |
| <a name="input_scale_out_evaluation_period"></a> [scale\_out\_evaluation\_period](#input\_scale\_out\_evaluation\_period) | Amount of time the average of scaling metric is evaluated over. | `string` | `"PT5M"` | no |
| <a name="input_scale_out_threshold"></a> [scale\_out\_threshold](#input\_scale\_out\_threshold) | Metric threshold for determining scale out. | `number` | `70` | no |
| <a name="input_scheduled_scaling_days_of_week"></a> [scheduled\_scaling\_days\_of\_week](#input\_scheduled\_scaling\_days\_of\_week) | Days of the week to apply scheduled scaling profile. | `list(string)` | <pre>[<br/>  "Monday",<br/>  "Tuesday",<br/>  "Wednesday",<br/>  "Thursday",<br/>  "Friday"<br/>]</pre> | no |
| <a name="input_scheduled_scaling_enabled"></a> [scheduled\_scaling\_enabled](#input\_scheduled\_scaling\_enabled) | Enable scheduled scaling on top of metric scaling. | `bool` | `false` | no |
| <a name="input_scheduled_scaling_end_time_hour"></a> [scheduled\_scaling\_end\_time\_hour](#input\_scheduled\_scaling\_end\_time\_hour) | Hour to end scheduled scaling profile. | `number` | `17` | no |
| <a name="input_scheduled_scaling_end_time_min"></a> [scheduled\_scaling\_end\_time\_min](#input\_scheduled\_scaling\_end\_time\_min) | Minute to end scheduled scaling profile. | `number` | `0` | no |
| <a name="input_scheduled_scaling_start_time_hour"></a> [scheduled\_scaling\_start\_time\_hour](#input\_scheduled\_scaling\_start\_time\_hour) | Hour to start scheduled scaling profile. | `number` | `9` | no |
| <a name="input_scheduled_scaling_start_time_min"></a> [scheduled\_scaling\_start\_time\_min](#input\_scheduled\_scaling\_start\_time\_min) | Minute to start scheduled scaling profile. | `number` | `0` | no |
| <a name="input_scheduled_scaling_timezone"></a> [scheduled\_scaling\_timezone](#input\_scheduled\_scaling\_timezone) | Timezone the times for the scheduled scaling profile are specified in. | `string` | `"Pacific Standard Time"` | no |
| <a name="input_scheduled_scaling_vmss_min_ccs"></a> [scheduled\_scaling\_vmss\_min\_ccs](#input\_scheduled\_scaling\_vmss\_min\_ccs) | Minimum number of CCs in vmss for scheduled scaling profile. | `number` | `2` | no |
| <a name="input_service_nsg_id"></a> [service\_nsg\_id](#input\_service\_nsg\_id) | Cloud Connector service interface nsg id | `string` | n/a | yes |
| <a name="input_service_subnet_id"></a> [service\_subnet\_id](#input\_service\_subnet\_id) | Cloud Connector service subnet id | `list(string)` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | SSH Key for instances | `string` | n/a | yes |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Cloud Init data | `string` | n/a | yes |
| <a name="input_vmss_default_ccs"></a> [vmss\_default\_ccs](#input\_vmss\_default\_ccs) | Default number of CCs in vmss. | `number` | `2` | no |
| <a name="input_vmss_max_ccs"></a> [vmss\_max\_ccs](#input\_vmss\_max\_ccs) | Maximum number of CCs in vmss. | `number` | `16` | no |
| <a name="input_vmss_min_ccs"></a> [vmss\_min\_ccs](#input\_vmss\_min\_ccs) | Minimum number of CCs in vmss. | `number` | `2` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Specify which availability zone(s) to deploy VM resources in if zones\_enabled variable is set to true | `list(string)` | <pre>[<br/>  "1"<br/>]</pre> | no |
| <a name="input_zones_enabled"></a> [zones\_enabled](#input\_zones\_enabled) | Determine whether to provision Cloud Connector VMs explicitly in defined zones (if supported by the Azure region provided in the location variable). If left false, Azure will automatically choose a zone and module will create an availability set resource instead for VM fault tolerance | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vmss_ids"></a> [vmss\_ids](#output\_vmss\_ids) | VMSS IDs |
| <a name="output_vmss_names"></a> [vmss\_names](#output\_vmss\_names) | VMSS Names |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
