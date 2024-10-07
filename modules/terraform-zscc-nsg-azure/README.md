# Zscaler Cloud Connector / Azure NSG Module

This module can be used to create default Management and Service interface NSG resources for Cloud Connector appliances. A count can be set to create once of each resource or potentially one per appliance if desired. As part of Zscaler provided deployment templates most resources have conditional create options leveraged "byo" variables should a customer want to leverage the module outputs with data reference to resources that may already exist in their Azure environment.

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
| [azurerm_network_security_group.cc_mgmt_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.cc_service_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.mgt_nsg_selected](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/network_security_group) | data source |
| [azurerm_network_security_group.service_nsg_selected](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/network_security_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_byo_mgmt_nsg_names"></a> [byo\_mgmt\_nsg\_names](#input\_byo\_mgmt\_nsg\_names) | Management Network Security Group ID for Cloud Connector association | `list(string)` | `null` | no |
| <a name="input_byo_nsg"></a> [byo\_nsg](#input\_byo\_nsg) | Bring your own network security group for Cloud Connector | `bool` | `false` | no |
| <a name="input_byo_service_nsg_names"></a> [byo\_service\_nsg\_names](#input\_byo\_service\_nsg\_names) | Service Network Security Group ID for Cloud Connector association | `list(string)` | `null` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Populate any custom user defined tags from a map | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Cloud Connector Azure Region | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the NSG module resources | `string` | `null` | no |
| <a name="input_nsg_count"></a> [nsg\_count](#input\_nsg\_count) | Default number of network security groups to create | `number` | `1` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Main Resource Group Name | `string` | n/a | yes |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the NSG module resources | `string` | `null` | no |
| <a name="input_support_access_enabled"></a> [support\_access\_enabled](#input\_support\_access\_enabled) | If Network Security Group is being configured, enable a specific outbound rule for Cloud Connector to be able to establish connectivity for Zscaler support access. Default is true | `bool` | `true` | no |
| <a name="input_zssupport_server"></a> [zssupport\_server](#input\_zssupport\_server) | destination IP address of Zscaler Support access server. IP resolution of remotesupport.<zscaler\_customer\_cloud>.net | `string` | `"199.168.148.101"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mgmt_nsg_id"></a> [mgmt\_nsg\_id](#output\_mgmt\_nsg\_id) | Management Network Security Group ID |
| <a name="output_service_nsg_id"></a> [service\_nsg\_id](#output\_service\_nsg\_id) | Service Network Security Group ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
