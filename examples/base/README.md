# Zscaler "Base" deployment type

This deployment type is just for greenfield/POV reference and/or spoke workload testing. It does not deploy any Cloud Connector appliances. Full set of resources provisioned list below, but this will effectively create all network infrastructure dependencies for an Azure environment. Creates 1 new Resource Group; 1 VNet with 1 public subnet and 1 private/workload subnet; 1 Centos server workload in the private subnet; 1 Bastion Host in the public subnet assigned a Public IP; and generates local key pair .pem file for ssh access.


## How to deploy:

### Option 1 (guided):
From the examples directory, run the zsec bash script that walks to all required inputs.
- ./zsec up
- enter "greenfield"
- enter "base"
- follow the remainder of the authentication and configuration input prompts.
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm

### Option 2 (manual):
Modify/populate any required variable input values in base/terraform.tfvars file and save.

From base directory execute:
- terraform init
- terraform apply

## How to destroy:

### Option 1 (guided):
From the examples directory, run the zsec bash script that walks to all required inputs.
- ./zsec destroy
- enter "greenfield"
- enter "base"

### Option 2 (manual):
From base directory execute:
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
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ../../modules/terraform-zscc-bastion-azure | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../modules/terraform-zscc-network-azure | n/a |
| <a name="module_workload"></a> [workload](#module\_workload) | ../../modules/terraform-zscc-workload-azure | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.testbed](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.save-key](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_arm_location"></a> [arm\_location](#input\_arm\_location) | The Azure Region where resources are to be deployed | `string` | `"westus2"` | no |
| <a name="input_bastion_nsg_source_prefix"></a> [bastion\_nsg\_source\_prefix](#input\_bastion\_nsg\_source\_prefix) | User input for locking down SSH access to bastion to a specific IP or CIDR range. Defaults to any IP | `string` | `"*"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Customer defined environment tag. ie: Dev, QA, Prod, etc. | `string` | `"Development"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The name prefix for all your resources | `string` | `"zsdemo"` | no |
| <a name="input_network_address_space"></a> [network\_address\_space](#input\_network\_address\_space) | VNET CIDR / address prefix | `string` | `"10.1.0.0/16"` | no |
| <a name="input_owner_tag"></a> [owner\_tag](#input\_owner\_tag) | Customer defined owner tag value. ie: Org, Dept, username, etc. | `string` | `"zscc-admin"` | no |
| <a name="input_tls_key_algorithm"></a> [tls\_key\_algorithm](#input\_tls\_key\_algorithm) | algorithm for tls\_private\_key resource | `string` | `"RSA"` | no |
| <a name="input_workload_count"></a> [workload\_count](#input\_workload\_count) | The number of Workload VMs to deploy | `number` | `1` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Specify which availability zone(s) to deploy VM resources in if zones\_enabled variable is set to true | `list(string)` | <pre>[<br>  "1"<br>]</pre> | no |
| <a name="input_zones_enabled"></a> [zones\_enabled](#input\_zones\_enabled) | Determine whether to provision Cloud Connector VMs explicitly in defined zones (if supported by the Azure region provided in the location variable). If left false, Azure will automatically choose a zone and module will create an availability set resource instead for VM fault tolerance | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_testbedconfig"></a> [testbedconfig](#output\_testbedconfig) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->