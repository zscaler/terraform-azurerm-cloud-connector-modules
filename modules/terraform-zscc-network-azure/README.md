# Zscaler Cloud Connector / Azure Network Infrastructure Module

This module has multi-purpose use and is leveraged by all other Zscaler Cloud Connector child modules in some capacity. All network infrastructure resources pertaining to connectivity dependencies for a successful Cloud Connector deployment in a private subnet are referenced here. Full list of resources can be found below, but in general this module will handle all Resource Group, VNet, Subnets, NAT Gateways, Public IP, and Route Table creations to build out a resilient Azure network architecture. Most resources also have "conditional create" capabilities where, by default, they will all be created unless instructed not to with various "byo" and "enabled" variables. Use cases are documented in more detail in each description in variables.tf as well as the terraform.tfvars example file for all non-base deployment types (ie: cc_lb, etc.).

## Private DNS Resolver Network Restrictions

<https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview> <br>

### Virtual network restrictions

The following restrictions hold with respect to virtual networks:

- A DNS resolver can only reference a virtual network in the same region as the DNS resolver.
- A virtual network can't be shared between multiple DNS resolvers. A single virtual network can only be referenced by a single DNS resolver.
<br>

### Subnet restrictions

Subnets used for DNS resolver have the following limitations:

- The following IP address space is reserved and can't be used for the DNS resolver service: 10.0.1.0 - 10.0.16.255.
- Do not use these class C networks or subnets within these networks for DNS resolver subnets: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24, 10.0.4.0/24, 10.0.5.0/24, 10.0.6.0/24, 10.0.7.0/24, 10.0.8.0/24, 10.0.9.0/24, 10.0.10.0/24, 10.0.11.0/24, 10.0.12.0/24, 10.0.13.0/24, 10.0.14.0/24, 10.0.15.0/24, 10.0.16.0/24.
- A subnet must be a minimum of /28 address space or a maximum of /24 address space.
- A subnet can't be shared between multiple DNS resolver endpoints. A single subnet can only be used by a single DNS resolver endpoint.
- All IP configurations for a DNS resolver inbound endpoint must reference the same subnet. Spanning multiple subnets in the IP configuration for a single DNS resolver inbound endpoint isn't allowed.
- The subnet used for a DNS resolver inbound endpoint must be within the virtual network referenced by the parent DNS resolver.
<br>
<br>
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
| [azurerm_nat_gateway.ngw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_association.ngw_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_public_ip.pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_route_table.private_dns_rt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_route_table.workload_rt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet.bastion_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.cc_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.private_dns_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.workload_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_nat_gateway_association.cc_subnet_nat_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_subnet_route_table_association.private_dns_rt_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_subnet_route_table_association.workload_rt_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_nat_gateway.ngw_selected](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/nat_gateway) | data source |
| [azurerm_public_ip.pip_selected](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip) | data source |
| [azurerm_resource_group.rg_selected](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.cc_subnet_selected](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.vnet_selected](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_only"></a> [base\_only](#input\_base\_only) | Default is false. Only applicable for base deployment type resulting in workload and bastion hosts, but no Cloud Connector resources. Setting this to true will point workload route able to Internet | `bool` | `false` | no |
| <a name="input_bastion_enabled"></a> [bastion\_enabled](#input\_bastion\_enabled) | Configure Bastion/Public Subnet if set to true | `bool` | `false` | no |
| <a name="input_byo_nat_gw_names"></a> [byo\_nat\_gw\_names](#input\_byo\_nat\_gw\_names) | User provided existing NAT Gateway resource names. This must be populated if byo\_nat\_gws variable is true | `list(string)` | `null` | no |
| <a name="input_byo_nat_gw_rg"></a> [byo\_nat\_gw\_rg](#input\_byo\_nat\_gw\_rg) | User provided existing NAT Gateway Resource Group. This must be populated if byo\_nat\_gws variable is true | `string` | `""` | no |
| <a name="input_byo_nat_gws"></a> [byo\_nat\_gws](#input\_byo\_nat\_gws) | Bring your own Azure NAT Gateways | `bool` | `false` | no |
| <a name="input_byo_pip_names"></a> [byo\_pip\_names](#input\_byo\_pip\_names) | User provided Azure Public IP address resource names to be associated to NAT Gateway(s) | `list(string)` | `null` | no |
| <a name="input_byo_pip_rg"></a> [byo\_pip\_rg](#input\_byo\_pip\_rg) | User provided Azure Public IP address resource group name. This must be populated if byo\_pip\_names variable is true | `string` | `""` | no |
| <a name="input_byo_pips"></a> [byo\_pips](#input\_byo\_pips) | Bring your own Azure Public IP addresses for the NAT Gateway(s) association | `bool` | `false` | no |
| <a name="input_byo_rg"></a> [byo\_rg](#input\_byo\_rg) | Bring your own Azure Resource Group. If false, a new resource group will be created automatically | `bool` | `false` | no |
| <a name="input_byo_rg_name"></a> [byo\_rg\_name](#input\_byo\_rg\_name) | User provided existing Azure Resource Group name. This must be populated if byo\_rg variable is true | `string` | `""` | no |
| <a name="input_byo_subnet_names"></a> [byo\_subnet\_names](#input\_byo\_subnet\_names) | User provided existing Azure subnet name(s). This must be populated if byo\_subnets variable is true | `list(string)` | `null` | no |
| <a name="input_byo_subnets"></a> [byo\_subnets](#input\_byo\_subnets) | Bring your own Azure subnets for Cloud Connector. If false, new subnet(s) will be created automatically. Default 1 subnet for Cloud Connector if 1 or no zones specified. Otherwise, number of subnes created will equal number of Cloud Connector zones | `bool` | `false` | no |
| <a name="input_byo_vnet"></a> [byo\_vnet](#input\_byo\_vnet) | Bring your own Azure VNet for Cloud Connector. If false, a new VNet will be created automatically | `bool` | `false` | no |
| <a name="input_byo_vnet_name"></a> [byo\_vnet\_name](#input\_byo\_vnet\_name) | User provided existing Azure VNet name. This must be populated if byo\_vnet variable is true | `string` | `""` | no |
| <a name="input_byo_vnet_subnets_rg_name"></a> [byo\_vnet\_subnets\_rg\_name](#input\_byo\_vnet\_subnets\_rg\_name) | User provided existing Azure VNET Resource Group. This must be populated if either byo\_vnet or byo\_subnets variables are true | `string` | `""` | no |
| <a name="input_cc_service_ip"></a> [cc\_service\_ip](#input\_cc\_service\_ip) | IP address of Cloud Connector Service IP. Used for non-ha greenfield deployment types like base\_cc so workload subnets automatically default route to this IP as next hop | `list(string)` | <pre>[<br/>  ""<br/>]</pre> | no |
| <a name="input_cc_subnets"></a> [cc\_subnets](#input\_cc\_subnets) | Cloud Connector Subnets to create in VNet. This is only required if you want to override the default subnets that this code creates via network\_address\_space variable. | `list(string)` | `null` | no |
| <a name="input_existing_nat_gw_pip_association"></a> [existing\_nat\_gw\_pip\_association](#input\_existing\_nat\_gw\_pip\_association) | Set this to true only if both byo\_pips and byo\_nat\_gws variables are true. This implies that there are already NAT Gateway resources with Public IP Addresses associated so we do not attempt any new associations | `bool` | `false` | no |
| <a name="input_existing_nat_gw_subnet_association"></a> [existing\_nat\_gw\_subnet\_association](#input\_existing\_nat\_gw\_subnet\_association) | Set this to true only if both byo\_nat\_gws and byo\_subnets variables are true. this implies that there are already NAT Gateway resources associated to subnets where Cloud Connectors are being deployed to | `bool` | `false` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Populate any custom user defined tags from a map | `map(string)` | `{}` | no |
| <a name="input_lb_enabled"></a> [lb\_enabled](#input\_lb\_enabled) | Default true. Configure Workload Route Table to default route next hop to the CC Load Balancer IP passed from var.lb\_frontend\_ip. If false, default route next hop directly to the CC Service IP passed from var.cc\_service\_ip | `bool` | `true` | no |
| <a name="input_lb_frontend_ip"></a> [lb\_frontend\_ip](#input\_lb\_frontend\_ip) | IP address of Cloud Connector Load Balancer frontend. Used for greenfield deployment types like base\_cc\_lb so workload subnets automatically default route to this IP as next hop | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Cloud Connector Azure Region | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the network module resources | `string` | `null` | no |
| <a name="input_network_address_space"></a> [network\_address\_space](#input\_network\_address\_space) | VNet IP CIDR Range. All subnet resources that might get created (public, workload, cloud connector) are derived from this /16 CIDR. If you require creating a VNet smaller than /16, you may need to explicitly define all other subnets via public\_subnets, workload\_subnets, cc\_subnets, and route53\_subnets variables | `string` | `"10.1.0.0/16"` | no |
| <a name="input_private_dns_subnet"></a> [private\_dns\_subnet](#input\_private\_dns\_subnet) | Private DNS Resolver Outbound Endpoint Subnet to create in VNet. This is only required if you want to override the default subnet that this code creates via network\_address\_space variable. | `string` | `null` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Public/Bastion Subnets to create in VNet. This is only required if you want to override the default subnets that this code creates via network\_address\_space variable. | `list(string)` | `null` | no |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the network module resources | `string` | `null` | no |
| <a name="input_workloads_enabled"></a> [workloads\_enabled](#input\_workloads\_enabled) | Configure Workload Subnets, Route Tables, and associations if set to true | `bool` | `false` | no |
| <a name="input_workloads_subnets"></a> [workloads\_subnets](#input\_workloads\_subnets) | Workload Subnets to create in VNet. This is only required if you want to override the default subnets that this code creates via network\_address\_space variable. | `list(string)` | `null` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Specify which availability zone(s) to deploy VM resources in if zones\_enabled variable is set to true | `list(string)` | <pre>[<br/>  "1"<br/>]</pre> | no |
| <a name="input_zones_enabled"></a> [zones\_enabled](#input\_zones\_enabled) | Determine whether to provision Cloud Connector VMs explicitly in defined zones (if supported by the Azure region provided in the location variable). If left false, Azure will automatically choose a zone and module will create an availability set resource instead for VM fault tolerance | `bool` | `false` | no |
| <a name="input_zpa_enabled"></a> [zpa\_enabled](#input\_zpa\_enabled) | Configure Private DNS Resolver Outbound Endpoint Subnet and route table for conditional forwarding to Cloud Connector if set to true | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_subnet_ids"></a> [bastion\_subnet\_ids](#output\_bastion\_subnet\_ids) | Bastion Host Subnet ID |
| <a name="output_cc_subnet_ids"></a> [cc\_subnet\_ids](#output\_cc\_subnet\_ids) | Cloud Connector Subnet ID |
| <a name="output_private_dns_subnet_id"></a> [private\_dns\_subnet\_id](#output\_private\_dns\_subnet\_id) | Private DNS Outbound Endpoint Subnet ID |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | Azure Public IP Address |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Azure Resource Group Name |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | Azure Virtual Network ID |
| <a name="output_workload_subnet_ids"></a> [workload\_subnet\_ids](#output\_workload\_subnet\_ids) | Workloads Subnet ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
