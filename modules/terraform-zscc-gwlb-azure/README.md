# Zscaler Cloud Connector / Azure Gateway Load Balancer Module

This module creates an Azure Gateway Load Balancer (SKU `Gateway`) with a private frontend IP, a backend address pool with dual VXLAN tunnel interfaces (internal + external), an HTTP health probe, and a load-balancing rule, to be used for transparent inline traffic inspection through Cloud Connector clusters.

The created GWLB is intended to be chained to a consumer Public Load Balancer (the `terraform-zscc-public-lb-azure` module, or any existing customer-managed PLB). Inbound traffic that hits the consumer PLB frontend is transparently redirected through this GWLB — which encapsulates the traffic in VXLAN and forwards it to backend Cloud Connectors for inspection — before being decapsulated and returned to the original destination.

## Pre-existing Load Balancers (Out of Scope)

Bringing your own (`byo_`) pre-existing GWLB is currently **out of scope** for this module. The same is true for the `terraform-zscc-lb-azure` Private LB module. Operators who already have a GWLB provisioned and only need to register Cloud Connector NICs into its backend pool should wire the NIC → backend-pool association outside this module. Uniform `byo_*` support across both Load Balancer modules may be addressed in a future release.

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
| [azurerm_lb.cc_gwlb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.cc_gwlb_backend_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.cc_gwlb_probe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.cc_gwlb_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Populate any custom user defined tags from a map | `map(string)` | `{}` | no |
| <a name="input_health_probe_interval"></a> [health\_probe\_interval](#input\_health\_probe\_interval) | The interval, in seconds, for how frequently to probe the endpoint for health status. The default value is 15, the minimum value is 5. | `number` | `15` | no |
| <a name="input_http_probe_port"></a> [http\_probe\_port](#input\_http\_probe\_port) | Port number for Cloud Connector cloud init to enable listener port for HTTP probe from Azure LB | `number` | `50000` | no |
| <a name="input_location"></a> [location](#input\_location) | Cloud Connector Azure Region | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the gwlb module resources | `string` | `null` | no |
| <a name="input_number_of_probes"></a> [number\_of\_probes](#input\_number\_of\_probes) | The number of probes where if no response, will result in stopping further traffic from being delivered to the endpoint. | `number` | `1` | no |
| <a name="input_probe_threshold"></a> [probe\_threshold](#input\_probe\_threshold) | The number of consecutive successful or failed probes in order to allow or deny traffic from being delivered to this endpoint. | `number` | `2` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Main Resource Group Name | `string` | n/a | yes |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the gwlb module resources | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID where the GWLB frontend IP is placed | `string` | n/a | yes |
| <a name="input_vxlan_external_port"></a> [vxlan\_external\_port](#input\_vxlan\_external\_port) | VXLAN external UDP port for traffic encapsulation | `number` | `10801` | no |
| <a name="input_vxlan_external_vni"></a> [vxlan\_external\_vni](#input\_vxlan\_external\_vni) | VXLAN external VNI for overlay traffic | `number` | `801` | no |
| <a name="input_vxlan_internal_port"></a> [vxlan\_internal\_port](#input\_vxlan\_internal\_port) | VXLAN internal UDP port for backend traffic forwarding | `number` | `10800` | no |
| <a name="input_vxlan_internal_vni"></a> [vxlan\_internal\_vni](#input\_vxlan\_internal\_vni) | VXLAN internal VNI for decapsulated traffic | `number` | `800` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Specify which availability zone(s) to deploy GWLB frontend IP in if zones\_enabled variable is set to true | `list(string)` | <pre>[<br/>  "1"<br/>]</pre> | no |
| <a name="input_zones_enabled"></a> [zones\_enabled](#input\_zones\_enabled) | Determine whether to provision the GWLB frontend IP explicitly in defined zones (if supported by the Azure region provided in the location variable). | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gwlb_backend_address_pool_id"></a> [gwlb\_backend\_address\_pool\_id](#output\_gwlb\_backend\_address\_pool\_id) | Azure Gateway Load Balancer backend address pool ID. Used to associate CC VM NICs to the GWLB backend |
| <a name="output_gwlb_frontend_ip_config_id"></a> [gwlb\_frontend\_ip\_config\_id](#output\_gwlb\_frontend\_ip\_config\_id) | Azure Gateway Load Balancer frontend IP configuration ID. Set this on the consumer Public Load Balancer frontend IP configuration to activate GWLB chaining |
| <a name="output_gwlb_ip"></a> [gwlb\_ip](#output\_gwlb\_ip) | Azure Gateway Load Balancer frontend private IP address |
| <a name="output_gwlb_probe_id"></a> [gwlb\_probe\_id](#output\_gwlb\_probe\_id) | Azure Gateway Load Balancer health probe ID |
| <a name="output_gwlb_rule_id"></a> [gwlb\_rule\_id](#output\_gwlb\_rule\_id) | Azure Gateway Load Balancer load balancing rule ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
