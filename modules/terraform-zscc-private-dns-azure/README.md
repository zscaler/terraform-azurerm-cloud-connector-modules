# Zscaler Cloud Connector / Azure DNS Private Resolver Module

This module creates the required resource dependencies to deploy Azure Private DNS that can be utilized to facilitate conditional DNS forwarding from Azure to Zscaler Cloud Connector for ZPA resolution and/or ZIA DNS Controls security. Resources included: Private DNS Resolver, Ruleset, Forwarding Rules, and Outbound Endpoint resources. For more information about Azure DNS Private Resolver, check here: https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview

See: [Private Resolver Architecture](https://learn.microsoft.com/en-us/azure/dns/private-resolver-architecture) for additional information discussing two architectural design options that are available to resolve DNS names, including private DNS zones across your Azure network using an Azure DNS Private Resolver.
See: [Private Resolver Resiliency/Reliability](https://learn.microsoft.com/en-us/azure/dns/private-resolver-reliability) for additional information describing reliability support in Azure DNS Private Resolver.



## Considerations

If deploying via one of the Zscaler provider example templates, there is a creation dependency with the terraform-zscc-network-azure module where Terraform will create a new subnet delegated for the dnsResolvers service in the same VNet as the Cloud Connector(s). This subnet is where the Outbound Endpoint gets created. Terraform will also create a new Route Table associated with this subnet pointing a default route (0.0.0.0/0) towards the Cloud Connector service IP or Load Balancer Front-End IP for HA deployments to ensure that conditionally forwarded request get redirected to the Cloud Connector.

This module can create multiple Resolver Rules and links associated with only a single VNet. This follows Azure Well-Architected Framework and Hub-Spoke design model where spokes have access/connectivity directly to the Hub Virtual Network.

Rule domain names must be dot-terminated and have either zero labels (for wildcard) or between 2 and 34 labels). For example, contoso.com. has two labels.

## Azure Limitations

https://learn.microsoft.com/en-us/azure/dns/dns-faq#what-are-the-usage-limits-for-azure-dns-:~:text=limits%20are%20dropped.-,DNS%20private%20resolver,-Resource

Rulesets have the following associations:

- A single ruleset can be associated with multiple outbound endpoints.
- A ruleset can have up to 25 DNS forwarding rules.
- A ruleset can be linked to up to 10 virtual networks in the same region

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

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.108.0, <= 3.116 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_resolver.dns_resolver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver) | resource |
| [azurerm_private_dns_resolver_dns_forwarding_ruleset.dns_forwarding_ruleset](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_dns_forwarding_ruleset) | resource |
| [azurerm_private_dns_resolver_forwarding_rule.dns_forwarding_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_forwarding_rule) | resource |
| [azurerm_private_dns_resolver_outbound_endpoint.dns_outbound_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_outbound_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_names"></a> [domain\_names](#input\_domain\_names) | Domain names fqdn/wildcard to have Azure Private DNS redirect DNS requests to Cloud Connector | `map(any)` | n/a | yes |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Populate any custom user defined tags from a map | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Specifies the Azure Region where the Private DNS Resolver should exist | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the Private DNS module resources | `string` | `null` | no |
| <a name="input_private_dns_subnet_id"></a> [private\_dns\_subnet\_id](#input\_private\_dns\_subnet\_id) | The ID of the Subnet that is linked to the Private DNS Resolver Outbound Endpoint | `string` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Specifies the name of the Resource Group where the Private DNS Resolver should exist | `string` | n/a | yes |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the Private DNS module resources | `string` | `null` | no |
| <a name="input_target_address"></a> [target\_address](#input\_target\_address) | Azure DNS queries will be conditionally forwarded to these target IP addresses. Default are a pair of Zscaler Global VIP addresses | `list(string)` | <pre>[<br/>  "185.46.212.88",<br/>  "185.46.212.89"<br/>]</pre> | no |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | The ID of the Virtual Network that is linked to the Private DNS Resolver | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_dns_forwarding_ruleset_id"></a> [private\_dns\_forwarding\_ruleset\_id](#output\_private\_dns\_forwarding\_ruleset\_id) | The ID of the Private DNS Resolver Dns Forwarding Ruleset. Use this if you want to link other Virtual Networks to this Ruleset |
| <a name="output_private_dns_forwarding_ruleset_name"></a> [private\_dns\_forwarding\_ruleset\_name](#output\_private\_dns\_forwarding\_ruleset\_name) | The name of the Private DNS Resolver Dns Forwarding Ruleset. Use this if you want to link other Virtual Networks to this Ruleset |
| <a name="output_private_dns_outbound_endpoint_id"></a> [private\_dns\_outbound\_endpoint\_id](#output\_private\_dns\_outbound\_endpoint\_id) | The ID of the Private DNS Resolver Outbound Endpoint |
| <a name="output_private_dns_outbound_endpoint_name"></a> [private\_dns\_outbound\_endpoint\_name](#output\_private\_dns\_outbound\_endpoint\_name) | The name of the Private DNS Resolver Outbound Endpoint |
| <a name="output_private_dns_resolver_id"></a> [private\_dns\_resolver\_id](#output\_private\_dns\_resolver\_id) | The ID of the Private DNS Resolver |
| <a name="output_private_dns_resolver_name"></a> [private\_dns\_resolver\_name](#output\_private\_dns\_resolver\_name) | The name of the Private DNS Resolver |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
