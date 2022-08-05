# Zscaler "cc_lb" deployment type

This deployment type is intended for brownfield/production purposes. By default, it will create a new Resource Group; 1 VNet; at least 1 Cloud Connector private subnet; at least 1 NAT Gateway with Public IP Address association to the Cloud Connector subnets; generates local key pair .pem file for ssh access; 1 Standard Azure Load Balancer with all rules, probes, and NIC associations.<br>

The number of Cloud Connectors can be customized via a "cc_count" variable. The number of Cloud Connector subnets, NAT Gateways, and Public IPs can vary based on if zones support is enabled and the amount of zone redundancy chosen.<br>

There are conditional create options for almost all dependent resources should they already exist (VNet, subnets, NAT Gateways, Public IPs, NSGs, etc.)


## How to deploy:

### Option 1 (guided):
From the examples directory, run the zsec bash script that walks to all required inputs.
- ./zsec up
- enter "brownfield"
- enter "cc_lb"
- follow the remainder of the authentication and configuration input prompts.
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm

### Option 2 (manual):
Modify/populate any required variable input values in cc_lb/terraform.tfvars file and save.

From cc_lb directory execute:
- terraform init
- terraform apply

## How to destroy:

### Option 1 (guided):
From the examples directory, run the zsec bash script that walks to all required inputs.
- ./zsec destroy
- enter "brownfield"
- enter "cc_lb"

### Option 2 (manual):
From cc_lb directory execute:
- terraform destroy

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 2.99.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.2.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.2.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.3.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 3.4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cc-identity"></a> [cc-identity](#module\_cc-identity) | ../../modules/terraform-zscc-identity-azure | n/a |
| <a name="module_cc-lb"></a> [cc-lb](#module\_cc-lb) | ../../modules/terraform-zscc-lb-azure | n/a |
| <a name="module_cc-nsg"></a> [cc-nsg](#module\_cc-nsg) | ../../modules/terraform-zscc-nsg-azure | n/a |
| <a name="module_cc-vm"></a> [cc-vm](#module\_cc-vm) | ../../modules/terraform-zscc-ccvm-azure | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../modules/terraform-zscc-network-azure | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.testbed](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.user-data-file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.cc-error-checker](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.save-key](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerated_networking_enabled"></a> [accelerated\_networking\_enabled](#input\_accelerated\_networking\_enabled) | Enable/Disable accelerated networking support on all Cloud Connector service interfaces | `bool` | `false` | no |
| <a name="input_arm_location"></a> [arm\_location](#input\_arm\_location) | The Azure Region where resources are to be deployed | `string` | `"westus2"` | no |
| <a name="input_azure_vault_url"></a> [azure\_vault\_url](#input\_azure\_vault\_url) | Azure Vault URL | `string` | n/a | yes |
| <a name="input_bastion_nsg_source_prefix"></a> [bastion\_nsg\_source\_prefix](#input\_bastion\_nsg\_source\_prefix) | user input for locking down SSH access to bastion to a specific IP or CIDR range | `string` | `"*"` | no |
| <a name="input_byo_mgmt_nsg_names"></a> [byo\_mgmt\_nsg\_names](#input\_byo\_mgmt\_nsg\_names) | Existing Management Network Security Group IDs for Cloud Connector VM association. This must be populated if byo\_nsg variable is true | `list(string)` | `null` | no |
| <a name="input_byo_nat_gw_names"></a> [byo\_nat\_gw\_names](#input\_byo\_nat\_gw\_names) | User provided existing NAT Gateway resource names. This must be populated if byo\_nat\_gws variable is true | `list(string)` | `null` | no |
| <a name="input_byo_nat_gw_rg"></a> [byo\_nat\_gw\_rg](#input\_byo\_nat\_gw\_rg) | User provided existing NAT Gateway Resource Group. This must be populated if byo\_nat\_gws variable is true | `string` | `""` | no |
| <a name="input_byo_nat_gws"></a> [byo\_nat\_gws](#input\_byo\_nat\_gws) | Bring your own Azure NAT Gateways | `bool` | `false` | no |
| <a name="input_byo_nsg"></a> [byo\_nsg](#input\_byo\_nsg) | Bring your own Network Security Groups for Cloud Connector | `bool` | `false` | no |
| <a name="input_byo_nsg_rg"></a> [byo\_nsg\_rg](#input\_byo\_nsg\_rg) | User provided existing NSG Resource Group. This must be populated if byo\_nsg variable is true | `string` | `""` | no |
| <a name="input_byo_pip_names"></a> [byo\_pip\_names](#input\_byo\_pip\_names) | User provided Azure Public IP address resource names to be associated to NAT Gateway(s) | `list(string)` | `null` | no |
| <a name="input_byo_pip_rg"></a> [byo\_pip\_rg](#input\_byo\_pip\_rg) | User provided Azure Public IP address resource group name. This must be populated if byo\_pip\_names variable is true | `string` | `""` | no |
| <a name="input_byo_pips"></a> [byo\_pips](#input\_byo\_pips) | Bring your own Azure Public IP addresses for the NAT Gateway(s) association | `bool` | `false` | no |
| <a name="input_byo_rg"></a> [byo\_rg](#input\_byo\_rg) | Bring your own Azure Resource Group. If false, a new resource group will be created automatically | `bool` | `false` | no |
| <a name="input_byo_rg_name"></a> [byo\_rg\_name](#input\_byo\_rg\_name) | User provided existing Azure Resource Group name. This must be populated if byo\_rg variable is true | `string` | `""` | no |
| <a name="input_byo_service_nsg_names"></a> [byo\_service\_nsg\_names](#input\_byo\_service\_nsg\_names) | Existing Service Network Security Group ID for Cloud Connector VM association. This must be populated if byo\_nsg variable is true | `list(string)` | `null` | no |
| <a name="input_byo_subnet_names"></a> [byo\_subnet\_names](#input\_byo\_subnet\_names) | User provided existing Azure subnet name(s). This must be populated if byo\_subnets variable is true | `list(string)` | `null` | no |
| <a name="input_byo_subnets"></a> [byo\_subnets](#input\_byo\_subnets) | Bring your own Azure subnets for Cloud Connector. If false, new subnet(s) will be created automatically. Default 1 subnet for Cloud Connector if 1 or no zones specified. Otherwise, number of subnes created will equal number of Cloud Connector zones | `bool` | `false` | no |
| <a name="input_byo_vnet"></a> [byo\_vnet](#input\_byo\_vnet) | Bring your own Azure VNet for Cloud Connector. If false, a new VNet will be created automatically | `bool` | `false` | no |
| <a name="input_byo_vnet_name"></a> [byo\_vnet\_name](#input\_byo\_vnet\_name) | User provided existing Azure VNet name. This must be populated if byo\_vnet variable is true | `string` | `""` | no |
| <a name="input_byo_vnet_subnets_rg_name"></a> [byo\_vnet\_subnets\_rg\_name](#input\_byo\_vnet\_subnets\_rg\_name) | User provided existing Azure VNET Resource Group. This must be populated if either byo\_vnet or byo\_subnets variables are true | `string` | `""` | no |
| <a name="input_cc_count"></a> [cc\_count](#input\_cc\_count) | The number of Cloud Connectors to deploy.  Validation assumes max for /24 subnet but could be smaller or larger as long as subnet can accommodate | `number` | `2` | no |
| <a name="input_cc_instance_size"></a> [cc\_instance\_size](#input\_cc\_instance\_size) | Cloud Connector Instance size. Determined by and needs to match the Cloud Connector Portal provisioning template configuration | `string` | `"small"` | no |
| <a name="input_cc_subnets"></a> [cc\_subnets](#input\_cc\_subnets) | Cloud Connector Subnets to create in VNet. This is only required if you want to override the default subnets that this code creates | `list(string)` | `null` | no |
| <a name="input_cc_vm_managed_identity_name"></a> [cc\_vm\_managed\_identity\_name](#input\_cc\_vm\_managed\_identity\_name) | Azure Managed Identity name to attach to the CC VM. E.g zspreview-66117-mi | `string` | n/a | yes |
| <a name="input_cc_vm_managed_identity_rg"></a> [cc\_vm\_managed\_identity\_rg](#input\_cc\_vm\_managed\_identity\_rg) | Resource Group of the Azure Managed Identity name to attach to the CC VM. E.g. edgeconnector\_rg\_1 | `string` | n/a | yes |
| <a name="input_cc_vm_prov_url"></a> [cc\_vm\_prov\_url](#input\_cc\_vm\_prov\_url) | Zscaler Cloud Connector Provisioning URL | `string` | n/a | yes |
| <a name="input_ccvm_image_offer"></a> [ccvm\_image\_offer](#input\_ccvm\_image\_offer) | Azure Marketplace Cloud Connector Image Offer | `string` | `"zia_cloud_connector"` | no |
| <a name="input_ccvm_image_publisher"></a> [ccvm\_image\_publisher](#input\_ccvm\_image\_publisher) | Azure Marketplace Cloud Connector Image Publisher | `string` | `"zscaler1579058425289"` | no |
| <a name="input_ccvm_image_sku"></a> [ccvm\_image\_sku](#input\_ccvm\_image\_sku) | Azure Marketplace Cloud Connector Image SKU | `string` | `"zs_ser_gen1_cc_01"` | no |
| <a name="input_ccvm_image_version"></a> [ccvm\_image\_version](#input\_ccvm\_image\_version) | Azure Marketplace Cloud Connector Image Version | `string` | `"latest"` | no |
| <a name="input_ccvm_instance_type"></a> [ccvm\_instance\_type](#input\_ccvm\_instance\_type) | Cloud Connector Image size | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_env_subscription_id"></a> [env\_subscription\_id](#input\_env\_subscription\_id) | Azure Subscription ID where resources are to be deployed in | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Customer defined environment tag. ie: Dev, QA, Prod, etc. | `string` | `"Development"` | no |
| <a name="input_existing_nat_gw_pip_association"></a> [existing\_nat\_gw\_pip\_association](#input\_existing\_nat\_gw\_pip\_association) | Set this to true only if both byo\_pips and byo\_nat\_gws variables are true. This implies that there are already NAT Gateway resources with Public IP Addresses associated so we do not attempt any new associations | `bool` | `false` | no |
| <a name="input_existing_nat_gw_subnet_association"></a> [existing\_nat\_gw\_subnet\_association](#input\_existing\_nat\_gw\_subnet\_association) | Set this to true only if both byo\_nat\_gws and byo\_subnets variables are true. this implies that there are already NAT Gateway resources associated to subnets where Cloud Connectors are being deployed to | `bool` | `false` | no |
| <a name="input_http_probe_port"></a> [http\_probe\_port](#input\_http\_probe\_port) | TCP port number for Cloud Connector cloud init to enable listener port for HTTP probe from LB | `number` | `0` | no |
| <a name="input_load_distribution"></a> [load\_distribution](#input\_load\_distribution) | Azure LB load distribution method | `string` | `"SourceIP"` | no |
| <a name="input_managed_identity_subscription_id"></a> [managed\_identity\_subscription\_id](#input\_managed\_identity\_subscription\_id) | Azure Subscription ID where the User Managed Identity resource exists. Only required if this Subscription ID is different than env\_subscription\_id | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The name prefix for all your resources | `string` | `"zsdemo"` | no |
| <a name="input_network_address_space"></a> [network\_address\_space](#input\_network\_address\_space) | VNET CIDR / address prefix | `string` | `"10.1.0.0/16"` | no |
| <a name="input_owner_tag"></a> [owner\_tag](#input\_owner\_tag) | Customer defined owner tag value. ie: Org, Dept, username, etc. | `string` | `"zscc-admin"` | no |
| <a name="input_reuse_nsg"></a> [reuse\_nsg](#input\_reuse\_nsg) | Specifies whether the NSG module should create 1:1 network security groups per instance or 1 network security group for all instances | `bool` | `"false"` | no |
| <a name="input_tls_key_algorithm"></a> [tls\_key\_algorithm](#input\_tls\_key\_algorithm) | algorithm for tls\_private\_key resource | `string` | `"RSA"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Specify which availability zone(s) to deploy VM resources in if zones\_enabled variable is set to true | `list(string)` | <pre>[<br>  "1"<br>]</pre> | no |
| <a name="input_zones_enabled"></a> [zones\_enabled](#input\_zones\_enabled) | Determine whether to provision Cloud Connector VMs explicitly in defined zones (if supported by the Azure region provided in the location variable). If left false, Azure will automatically choose a zone and module will create an availability set resource instead for VM fault tolerance | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_testbedconfig"></a> [testbedconfig](#output\_testbedconfig) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->