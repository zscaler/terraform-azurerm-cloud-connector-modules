## 0.1.0 (July 13, 2022)
* github release refactor
* zsec update for terraform support up to 1.1.9
* zsec updated with mac m1 option for terraform arm64 version download
* azurerm provider updated to 2.99.0 for all module support and deployment types
* modules renamed for granularity and consistency
* azurerm_public_ip resource updated per Network API version 2020-08-01 (https://azure.microsoft.com/en-us/updates/zone-behavior-change/)
* NSG resources broken out into individual child module with reuse and byo nsg added
* zsec enhancement inputs
* ZS-17339 - support for Managed Identities in different Azure Subsciptions
* Managed Identity resource broken out into individual child module
* zsec full service deployment support
* terraform.tfvars customized per deployment type
* base_cc renamed to base_1cc
* bug-124439 - accelerated_networking_enabled variable added to service interfaces. left default false for now until support added
* workload and bastion hosts changed from ubuntu to centos
* added TF_DATA_DIR to zsec and backend.tf to each deployment type to maintain root path as "examples/" directory for all deployments


previous changelog would all disappear
################################################################

## 1.1.2 (June 13, 2022)
NOTES:
* Initial check-in
* terraform-zscc-azure module refactoring to accommodate medium/large Cloud Connector instance size creations and load balancer association
* terraform.tfvars options added for ccvm_instance_type and cc_instance_size
* validation checks added to ensure ccvm_instance_type and cc_instance_size selections are compatible/permitted

## 1.1.1 (May 24, 2022)
NOTES:
* New Azure Image SKU released to marketplace. zs_ser_gen1_cc_01 (replacing zs_ser_cc_03). Please make sure to accept the new image terms prior to deployment. E.g. az vm image terms accept --urn zscaler1579058425289:zia_cloud_connector:zs_ser_gen1_cc_01:latest
* Zone based Cloud Connectors and network resources support added
* Azure Load Balancer code removed from terraform-zscc-azure module and replaced with its own dedicated module. "backend_address_pool" variable added to terraform-zscc-azure module. Removed terraform-zscc-lb-azure module
* To accommodate non-lb deployment types, variable "lb_association_enabled" added to terraform-zscc-azure module to instruct whether to create service nic assocations to a specified backend pool or not
* Counts added to the service and management NSGs to create 1 per CC deployed to match marketplace and other cloud deployment models
* Cleanup to CC NSG match criteria and priority numbering
* Changed variable "ccvm_instance_size" to "ccvm_instance"type" for consistency with other clouds.
* Standard_DS3_v2 VM type support added
* Renames: deployment type cc_lb to cc_lb_custom; byo variables '_name' to '_names' and converted from list to list(string) if multiple entries are supported; terraform resource name standardization. These changes will require modification if trying to incorporate new module code w/ existing terraform state files

ENCHANCEMENTS:
* Variables "zones" and "zones_enabled" added. If zones enabled, a count will increment based on the unique zones specified the number of Cloud Connector Subnets associated with Zonal NAT Gateway and PIP resource creations
* Default for multiple Cloud Connector creations is single subnet w/ availability sets. However, enabling zones (if supported by Azure region constraints) will deploy CCs in unique subnets logically tied to those zones and loop through each new appliance creation in the specified zone(s). This will also disable the availabilty set creation.
* Terraform-zsworkload-azure module: count added to nsg, name cleanup, and variable "dns_servers" added
* Variable "location" added to all appliance modules
* Validation logic added to all zonal selectable resources to confirm that the region selected will support zone based deployments of the Cloud Connector VM type. This can be checked per customer subscription w/ commend: az vm list-skus --size Standard_D2s_v3 --all --output table
* For availability set deployments, validation logic added to use max platform fault domain of 3 if region supports it. Otherwise fall back to 2 fault domains
* Variable "global_tags" added for all tagged resources to support newer versions of terraform as well as custom commpliance tagging ease

BUGS:
* BUG-117623: Support for zonal deployments of Public IP, NAT Gateway, and Cloud Connector resources via dynamic zones and zones_enabled variables
* BUG-120807: backend pool association explicit dependency on azurerm_lb_backend_address_pool

## 1.1.0 (September 7, 2021)
NOTES:
* Updated README to include prerequisites to accept vm image terms
* Additional details for minimum Managed Identity custom role permissions
* Removed ccvm_instance_size selection
* Variable naming syntax standardization
* General README and descriptions cleanup
* Renamed base_1cc to base_cc
* Removed uneccesary base deployment resource creations
* Removed byo_pip_address for base greenfield deployment types
* Modified base deployment types for single /24 CC subnet configuration

ENHANCEMENTS:
* New cc_lb deployment type for just cloud connector + lb deployment brownfield deployments. Mirror of Azure Marketplace deployment w/ customization capabilities
* Custom variable options added to enable/disable bring-your-own resources for Cloud Connector deployment in existing environments. Custom paramaters include: BYO existing Resource Group, PIP, NAT Gateway and associations, VNET, subnet and address space.
* Added network_address_space and cc_subnet variable to terraform.tfvars for users to easily modify/define their own VNET and subnet sizes

BUGS:
* base deployment variables and output syntax fixes


## 1.0.1 (August 24, 2021)
ENHANCEMENTS:
* ccvm-instance-size validation constraints added


## 1.0.0 (August 24, 2021)

NOTES:
* Initial code revision check-in

ENHANCEMENTS:
* terraform-zscc-lb-azure module for multi-cloud connector deployments behind Azure LB
* terraform.tfvars additions: http-probe-port for CC listener service + LB health probing; cc_count + vm_count customizations for scaled deployment testing; ccvm-instance-size for Azure VM size selections

FEATURES:
* Customer solutioned POV templates for greenfield/brownfield Azure Cloud Connector Deployments
* Sanitized README file
* ZSEC updated for new deployment type selections

BUG FIXES: 
* N/A
