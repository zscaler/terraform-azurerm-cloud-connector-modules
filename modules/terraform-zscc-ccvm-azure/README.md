# Zscaler Cloud Connector / Azure VM (Cloud Connector) Module

This module creates all the necessary VM, Network Interface, and NSG/LB associations for a successful Cloud Connector deployment

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 2.99.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 2.99.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_availability_set.cc-availability-set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set) | resource |
| [azurerm_linux_virtual_machine.cc-vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.cc-mgmt-nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface.cc-service-nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface.cc-service-nic-1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface.cc-service-nic-2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface.cc-service-nic-3](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_backend_address_pool_association.cc-vm-service-1-nic-lb-association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_network_interface_backend_address_pool_association.cc-vm-service-2-nic-lb-association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_network_interface_backend_address_pool_association.cc-vm-service-3-nic-lb-association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_network_interface_backend_address_pool_association.cc-vm-service-nic-lb-association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_network_interface_security_group_association.cc-mgmt-nic-association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_interface_security_group_association.cc-service-nic-1-association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_interface_security_group_association.cc-service-nic-2-association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_interface_security_group_association.cc-service-nic-3-association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_interface_security_group_association.cc-service-nic-association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [null_resource.error-checker](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azurerm_subscription.current-subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerated_networking_enabled"></a> [accelerated\_networking\_enabled](#input\_accelerated\_networking\_enabled) | Enable/Disable accelerated networking support on all Cloud Connector service interfaces | `bool` | `false` | no |
| <a name="input_backend_address_pool"></a> [backend\_address\_pool](#input\_backend\_address\_pool) | Azure LB Backend Address Pool ID for NIC association | `string` | `null` | no |
| <a name="input_cc_count"></a> [cc\_count](#input\_cc\_count) | The number of Cloud Connectors to deploy.  Validation assumes max for /24 subnet but could be smaller or larger as long as subnet can accommodate | `number` | `1` | no |
| <a name="input_cc_instance_size"></a> [cc\_instance\_size](#input\_cc\_instance\_size) | n/a | `string` | `"small"` | no |
| <a name="input_cc_username"></a> [cc\_username](#input\_cc\_username) | Default Cloud Connector admin/root username | `string` | `"zsroot"` | no |
| <a name="input_ccvm_image_offer"></a> [ccvm\_image\_offer](#input\_ccvm\_image\_offer) | Azure Marketplace Cloud Connector Image Offer | `string` | `"zia_cloud_connector"` | no |
| <a name="input_ccvm_image_publisher"></a> [ccvm\_image\_publisher](#input\_ccvm\_image\_publisher) | Azure Marketplace Cloud Connector Image Publisher | `string` | `"zscaler1579058425289"` | no |
| <a name="input_ccvm_image_sku"></a> [ccvm\_image\_sku](#input\_ccvm\_image\_sku) | Azure Marketplace Cloud Connector Image SKU | `string` | `"zs_ser_gen1_cc_01"` | no |
| <a name="input_ccvm_image_version"></a> [ccvm\_image\_version](#input\_ccvm\_image\_version) | Azure Marketplace Cloud Connector Image Version | `string` | `"latest"` | no |
| <a name="input_ccvm_instance_type"></a> [ccvm\_instance\_type](#input\_ccvm\_instance\_type) | Cloud Connector Image size | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Populate any custom user defined tags from a map | `map(string)` | `{}` | no |
| <a name="input_http_probe_port"></a> [http\_probe\_port](#input\_http\_probe\_port) | TCP Port number for Cloud Connector cloud init to enable listener port for HTTP probe from LB. Default is 0 which effectively disables the listener service so customer must specify a valid number to enable | `number` | `0` | no |
| <a name="input_lb_association_enabled"></a> [lb\_association\_enabled](#input\_lb\_association\_enabled) | Determines whether or not to create a nic backend pool assocation to the service nic(s) | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Cloud Connector Azure Region | `string` | n/a | yes |
| <a name="input_managed_identity_id"></a> [managed\_identity\_id](#input\_managed\_identity\_id) | ID of the User Managed Identity assigned to Cloud Connector VM | `string` | n/a | yes |
| <a name="input_mgmt_nsg_id"></a> [mgmt\_nsg\_id](#input\_mgmt\_nsg\_id) | Cloud Connector management interface nsg id | `list(string)` | n/a | yes |
| <a name="input_mgmt_subnet_id"></a> [mgmt\_subnet\_id](#input\_mgmt\_subnet\_id) | Cloud Connector management subnet id. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the Bastion Host module resources | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Main Resource Group Name | `string` | n/a | yes |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the Bastion Host module resources | `string` | `null` | no |
| <a name="input_service_nsg_id"></a> [service\_nsg\_id](#input\_service\_nsg\_id) | Cloud Connector service interface(s) nsg id | `list(string)` | n/a | yes |
| <a name="input_service_subnet_id"></a> [service\_subnet\_id](#input\_service\_subnet\_id) | Cloud Connector service subnet id | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | SSH Key for instances | `string` | n/a | yes |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Cloud Init data | `string` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | Specify which availability zone(s) to deploy VM resources in if zones\_enabled variable is set to true | `list(string)` | <pre>[<br>  "1"<br>]</pre> | no |
| <a name="input_zones_enabled"></a> [zones\_enabled](#input\_zones\_enabled) | Determine whether to provision Cloud Connector VMs explicitly in defined zones (if supported by the Azure region provided in the location variable). If left false, Azure will automatically choose a zone and module will create an availability set resource instead for VM fault tolerance | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cc_hostname"></a> [cc\_hostname](#output\_cc\_hostname) | n/a |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | n/a |
| <a name="output_service_ip"></a> [service\_ip](#output\_service\_ip) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->