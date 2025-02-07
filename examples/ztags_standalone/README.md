# Zscaler "Z-Tags Standalone" deployment type

Use this template to deploy an Azure Event Grid System Topic + PartnerDestination Event Subscription in a new or existing Resource Group. This enables Zscaler to send and receive event notifications for new resource add/delete/change operations for a designated source Subscription. No Cloud Connector resources are provisioned with this template as the dependency of this feature assumes the resources already exist.

## Caveats/Considerations
- WSL2 DNS bug: If you are trying to run these Azure terraform deployments specifically from a Windows WSL2 instance like Ubuntu and receive an error containing a message similar to this "dial tcp: lookup management.azure.com on 172.21.240.1:53: cannot unmarshal DNS message" please refer here for a WSL2 resolv.conf fix. https://github.com/microsoft/WSL/issues/5420#issuecomment-646479747.

## How to deploy:

### Option 1 (guided):
From the examples directory, run the zsec bash script that walks to all required inputs.
- ./zsec up
- enter "3 for standalone - Zscaler Tags Enablement"
- follow the remainder of the authentication and configuration input prompts.
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm

### Option 2 (manual):
Modify/populate any required variable input values in ztags_standalone/terraform.tfvars file and save.

From base directory execute:
- terraform init
- terraform apply

## How to destroy:

### Option 1 (guided):
From the examples directory, run the zsec bash script that walks to all required inputs.
- ./zsec destroy

### Option 2 (manual):
From ztags_standalone directory execute:
- terraform destroy

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.108.0, <= 3.116 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ztags"></a> [ztags](#module\_ztags) | ../../modules/terraform-zscc-ztags-azure | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.testbed](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_arm_location"></a> [arm\_location](#input\_arm\_location) | The Azure Region where resources are to be deployed | `string` | `"westus2"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Customer defined environment tag. ie: Dev, QA, Prod, etc. | `string` | `"Development"` | no |
| <a name="input_existing_ztags_rg_name"></a> [existing\_ztags\_rg\_name](#input\_existing\_ztags\_rg\_name) | Existing Resource Group name to create Z-Tag resources | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The name prefix for all your resources | `string` | `"zstags"` | no |
| <a name="input_owner_tag"></a> [owner\_tag](#input\_owner\_tag) | Customer defined owner tag value. ie: Org, Dept, username, etc. | `string` | `"zscc-admin"` | no |
| <a name="input_partnerdestination_id"></a> [partnerdestination\_id](#input\_partnerdestination\_id) | Zscaler registered PartnerDestination ID. example: /subscriptions/<subscriptionId>/resourceGroups/<partnerResourceGroup/providers/Microsoft.EventGrid/partnerDestinations/<partnerDestinationName> | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Optional) Azure Subscription ID for Event Grid System Topic source property. If none specified, resource will use caller subscription id | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_testbedconfig"></a> [testbedconfig](#output\_testbedconfig) | Azure Testbed results |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
