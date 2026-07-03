# Zscaler Cloud Connector / Azure Public Load Balancer Module

This module creates a Standard Public Load Balancer with a Public IP frontend, backend address pool, TCP rules (ports 80 and 443), and HTTP health probe, to be used with Cloud Connector clusters that require inbound DNAT (e.g. the `fwd ZIA` feature).

The module can be used in two modes:

1. **Standalone Public LB** — the Public IP frontend distributes inbound traffic directly to CC backend NICs (or VMSS instances). Used by `base_cc_public_lb` and `base_cc_public_vmss` examples.
2. **Consumer LB chained to a Gateway Load Balancer** — when `gateway_load_balancer_frontend_ip_configuration_id` is set, inbound traffic at the Public IP frontend is transparently redirected through the GWLB (and its CC VMs/VMSS) before reaching the original destination. Used by all GWLB examples when `create_consumer_public_lb = true`.

LB rules have `enable_floating_ip = true`. This is required to support DNAT for the `fwd ZIA` feature. There is no side effect when used standalone — the Public LB is a passthrough LB and its VIP is not currently used by the backend.

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
| [azurerm_lb.cc_lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.cc_lb_backend_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.cc_lb_probe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.cc_lb_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_lb_rule.cc_lb_rule_443](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_public_ip.frontend_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gateway_load_balancer_frontend_ip_configuration_id"></a> [gateway\_load\_balancer\_frontend\_ip\_configuration\_id](#input\_gateway\_load\_balancer\_frontend\_ip\_configuration\_id) | The ID of the Gateway Load Balancer frontend IP configuration to chain this Public Load Balancer to. When set, all traffic through this PLB frontend will be transparently redirected through the GWLB (and its CC VMs) before reaching the backend. Leave null to disable GWLB chaining. | `string` | `null` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Populate any custom user defined tags from a map | `map(string)` | `{}` | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | The interval, in seconds, for how frequently to probe the endpoint for health status. Typically, the interval is slightly less than half the allocated timeout period (in seconds) which allows two full probes before taking the instance out of rotation. The default value is 15, the minimum value is 5 | `number` | `15` | no |
| <a name="input_http_probe_port"></a> [http\_probe\_port](#input\_http\_probe\_port) | Port number for Cloud Connector cloud init to enable listener port for HTTP probe from Azure LB | `number` | `50000` | no |
| <a name="input_load_distribution"></a> [load\_distribution](#input\_load\_distribution) | Azure LB load distribution method | `string` | `"Default"` | no |
| <a name="input_location"></a> [location](#input\_location) | Cloud Connector Azure Region | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the lb module resources | `string` | `null` | no |
| <a name="input_number_of_probes"></a> [number\_of\_probes](#input\_number\_of\_probes) | The number of probes where if no response, will result in stopping further traffic from being delivered to the endpoint. This values allows endpoints to be taken out of rotation faster or slower than the typical times used in Azure | `number` | `1` | no |
| <a name="input_probe_threshold"></a> [probe\_threshold](#input\_probe\_threshold) | The number of consecutive successful or failed probes in order to allow or deny traffic from being delivered to this endpoint. After failing the number of consecutive probes equal to this value, the endpoint will be taken out of rotation and require the same number of successful consecutive probes to be placed back in rotation. | `number` | `2` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Main Resource Group Name | `string` | n/a | yes |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the lb module resources | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for LB Frontend IP placement | `string` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | Specify which availability zone(s) to deploy VM resources in if zones\_enabled variable is set to true | `list(string)` | <pre>[<br/>  "1"<br/>]</pre> | no |
| <a name="input_zones_enabled"></a> [zones\_enabled](#input\_zones\_enabled) | Determine whether to provision Cloud Connector VMs explicitly in defined zones (if supported by the Azure region provided in the location variable). If left false, Azure will automatically choose a zone and module will create an availability set resource instead for VM fault tolerance | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_backend_address_pool"></a> [lb\_backend\_address\_pool](#output\_lb\_backend\_address\_pool) | Azure Public Load Balancer Backend Pool ID |
| <a name="output_lb_ip"></a> [lb\_ip](#output\_lb\_ip) | Azure Public Load Balancer Frontend IP |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
