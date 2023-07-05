## TBD (Unreleased)
* Add encryption_at_host_enabled variable and default to true

## v0.3.0 (April 4, 2023)
* Azure Private DNS module (terraform-zscc-private-dns-azure)
* New greenfield deployment options (base_1cc_zpa and base_cc_lb_zpa) with Azure Private DNS module integration
* zpa_enabled variable added to dynamically create Outbound DNS subnet and Route Table in VNet if set to true
* zsec additions for new deployment options + domains adding to Private DNS Resolver Rule creation
* workload VM for greenfield deployments dns_servers set to Azure DNS default
* terraform-zscc-network-azure refactoring to remove data source read dependencies

## v0.2.0 (March 7, 2023)

* Mininum Azure Provider upgrade from 2.x to 3.x (3.46.x)
* refactor resources for 3.x provider: azurerm_public_ip, azurerm_lb_probe, and cc_lb_rule
* Fix for Azure Load Balancer frontend_ip creation in Regions that do not support availability zones. If a single zone is specified to variable "zones" and variable "zones_enabled" is true then the frontend_ip will be created in that single zone. If more than one zone is specified, we will default to all 3 zones (zone-redundant) to follow Azure Network API
* Fix for NSG data source read dependency when resource orginally created (byo_nsg = false) forcing recreate on subsequent terraform applies

## v0.1.1 (December 16, 2022)

* comprehensive README
* variable condition tonumber. terraform #30919
* tflint terraform_deprecated_index
* public ip conditional create logic
* private_ip_address_allocation capitalize
* add westus3 zone support
* update codeowners

## v0.1.0 (December 15, 2022)

* github release refactor from Cloud Connector Portal
* zsec update for terraform support up to 1.1.9
* zsec updated with mac m1 option for terraform arm64 version download
* azurerm provider updated to 2.99.0 for all module support and deployment types
* modules renamed for granularity and consistency
* azurerm_public_ip resource updated per Network API version 2020-08-01 (<https://azure.microsoft.com/en-us/updates/zone-behavior-change/>)
* NSG resources broken out into individual child module with reuse and byo nsg added
* zsec enhancement inputs
* support for Managed Identities in different Azure Subsciptions
* Managed Identity resource broken out into individual child module
* zsec full service deployment support
* terraform.tfvars customized per deployment type
* base_cc renamed to base_1cc
* accelerated_networking_enabled variable added to service interfaces.
* workload and bastion hosts changed from ubuntu to centos
* added TF_DATA_DIR to zsec and backend.tf to each deployment type to maintain root path as "examples/" directory for all deployments
* dropped "custom" from deployment types as brownfield is implicit
* vm_count replaced with workload_count for clarity
* network infrastructure resources consolidated to terraform-zscc-network-azure module. Inputs refactored.
* added custom subnet definition capabilities via variables cc_subnets, public_subnets, and workloads_subnets should customer try to override network_address_space and the auto cidrsubnet selection becomes incompatible
* cc-error-checker changes to run first so errors thrown are less and clearer in the event of a CC deployment configuration error
