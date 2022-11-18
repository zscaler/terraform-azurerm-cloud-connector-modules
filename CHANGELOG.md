## v0.2.0 (November 17, 2022)
* Azure Private DNS module (terraform-zscc-private-dns-azure)
* azurerm provider updated to 3.31.0. Minor resource refactoring to Azure LB and Public IP
* New greenfield deployment options (base_1cc_zpa and base_cc_lb_zpa) with Azure Private DNS module integration
* zpa_enabled variable added to dynamically create Outbound DNS subnet and Route Table in VNet if set to true
* zsec additions for new deployment options + domains adding to Private DNS Resolver Rule creation
* workload VM for greenfield deployments dns_servers set to Azure DNS default


## 0.1.0 (July 13, 2022)

* github release refactor
* zsec update for terraform support up to 1.1.9
* zsec updated with mac m1 option for terraform arm64 version download
* azurerm provider updated to 2.99.0 for all module support and deployment types
* modules renamed for granularity and consistency
* azurerm_public_ip resource updated per Network API version 2020-08-01 (<https://azure.microsoft.com/en-us/updates/zone-behavior-change/>)
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
* dropped "custom" from deployment types as brownfield is implicit
* vm_count replaced with workload_count for clarity
* network infrastructure resources consolidated to terraform-zscc-network-azure module. Inputs refactored.
* added custom subnet definition capabilities via variables cc_subnets, public_subnets, and workloads_subnets should customer try to override network_address_space and the auto cidrsubnet selection becomes incompatible
* cc-error-checker changes to run first so errors thrown are less and clearer in the event of a CC deployment configuration error
