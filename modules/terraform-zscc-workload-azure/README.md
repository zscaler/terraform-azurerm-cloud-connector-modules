# Zscaler Cloud Connector / Azure VM (Workload) Module

This module creates all Azure VM and NSG resources needed to deploy test workloads for Cloud Connector Greenfield/POV environments.

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

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.workload_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.workload_nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.workload_nic_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.workload_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers configured for workload VMs. | `list(string)` | `[]` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Populate any custom user defined tags from a map | `map(string)` | `{}` | no |
| <a name="input_instance_image_offer"></a> [instance\_image\_offer](#input\_instance\_image\_offer) | The workload image offer | `string` | `"almalinux-x86_64"` | no |
| <a name="input_instance_image_publisher"></a> [instance\_image\_publisher](#input\_instance\_image\_publisher) | The workload image publisher | `string` | `"almalinux"` | no |
| <a name="input_instance_image_sku"></a> [instance\_image\_sku](#input\_instance\_image\_sku) | The workload image sku | `string` | `"9-gen1"` | no |
| <a name="input_instance_image_version"></a> [instance\_image\_version](#input\_instance\_image\_version) | The workload image version | `string` | `"latest"` | no |
| <a name="input_instance_size"></a> [instance\_size](#input\_instance\_size) | The Azure image type/size | `string` | `"Standard_B1s"` | no |
| <a name="input_location"></a> [location](#input\_location) | Cloud Connector Azure Region | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the workload module resources | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Main Resource Group Name | `string` | n/a | yes |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the workload module resources | `string` | `null` | no |
| <a name="input_server_admin_username"></a> [server\_admin\_username](#input\_server\_admin\_username) | Username configured for the workload root/admin account | `string` | `"almalinux"` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | SSH Key for instances | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The id of subnet where the workload host has to be attached | `string` | n/a | yes |
| <a name="input_workload_count"></a> [workload\_count](#input\_workload\_count) | The number of Workload VMs to deploy | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | Instance Admin Username |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Instance Private IP Address |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
