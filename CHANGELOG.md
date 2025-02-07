## v0.7.0 (March 10, 2025)

FEATURES:
* New Azure Region supported by Cloud Connector: Spain Central

FEATURES:
* Official support for Zscaler Azure Tag Discovery Service
* add: new examples ztags_standalone and module terraform-zscc-ztags-azure

ENHANCEMENTS:
* add: zsec support for Zscaler Azure Tag Discovery Service configuration
* add: AzAPI provider (version 2.2.x) support for configuring Azure Event Grid resources
* refactor: **support for future features** add base64 encoded user_data to VM and VMSS UserData attribute. CustomData will still be utilized until a future VHD release. At that time, it will remain as a secondary fallback to preferred UserData.
* refactor: include ssh_config generation with auto mapping all workload/cc instances for base/greenfield deployments
* refactor: change base/greenfield workload and bastion virtual machines from CentOS 7.5 to AlmaLinux 9


BUG FIXES:
* update az_supported_regions static map for all modules


## v0.6.2 (December 9, 2024)

BUG FIXES:
* fix: VMSS improvements with new [Zscaler Function Zip file v1.0.1](modules/terraform-zscc-function-app-azure/zscaler_cc_function_app.zip)

ENHANCEMENTS:
* zsec support for Zscaler Cloud: zscalergov.net

## v0.6.1 (October 5, 2024)

BUG FIXES:
* AzureRM Provider version bump to 3.116.x default to address provider: skip registration for resource providers that are unavailable
* refactor: update Azure deprecated arguments:
    - azurerm_network_interface: enable_ip_forwarding change to ip_forwarding_enabled and enable_accelerated_networking to accelerated_networking_enabled
    - azurerm_route_table: disable_bgp_route_propagation (default true) change to bgp_route_propagation_enabled (default false)

ENHANCEMENTS:
* zsec support server lookup resiliency improvements

## v0.6.0 (September 5, 2024)

ENHANCEMENTS:
* refactor: code cleanup for unused variables and UX

FEATURES:
* Virtual Machine Scale Sets (VMSS) Support - (Requires new VHD version 24.3.2)
    - add: module terraform-zscc-ccvmss-azure for flexible orchestration VMSS and scaling policy template
    - add: module terraform-zscc-function-app-azure for Function App and dependency resources
    - add: module terraform-acc-identity-azure support for CC/VMSS and Function App Managed Identity separation
    - add: zsec script support for VMSS greenfield and brownfield deployments


## v0.5.1 (August 26, 2024)

ENHANCEMENTS:
* feat: Official Azure Marketplace support for both usgovernment and china Azure Clouds. Product information for each can be located [here](https://github.com/zscaler/terraform-azurerm-cloud-connector-modules/tree/main/modules/terraform-zscc-ccvm-azure/README.md)

BUG FIXES:
* fix: remove local file depends_on to avoid conflicts if file does not exist or needs recreated

## v0.5.0 (May 22, 2024)

FEATURES:
* add: terraform and zsec support for Azure Government ARM_ENVIRONMENT and regions

ENHANCEMENTS:
* add: var zssupport_server to nsg module
* add: zsec automatic lookup zssupport server IP for destination NSG rule by Zscaler Cloud

## v0.4.1 (February 29, 2024)

BUG FIXES:
* ZSEC bash script fixes
* update az_supported_regions static map to include regions: East US 2, Switzerland North, and UAE North availability zones support

## v0.4.0 (December 16, 2023)

FEATURES:
* Azure China support (China East, China East 2, China North, China North 2, and China North 3)

BUG FIXES:
* fix: brownfield cc_lb defaults for non-zpa private dns deployments
  
ENHANCEMENTS:
* ZSEC bash script support for Azure China regions
* add: variable support_access_enabled for dynamic NSG rule creation for Zscaler Support Tunnel access
* add: zsec prompt for support tunnel rule creation
* add: Standard_DS2_v2 size support
* ZSEC bash script refactoring

## v0.3.0 (September 30, 2023)

FEATURES:
* Azure Private DNS module (terraform-zscc-private-dns-azure)
    - add: deployment types base_1cc_zpa/base_cc_lb_zpa (greenfield/pov/test) with Azure Private DNS module integration
    - add: conditional variable zpa_enabled for cc_lb (brownfield/prod) deployment for Azure Private DNS module integration
    - add: zsec additions for new deployment options + domains adding to Private DNS Resolver Rule creation
* AzureRM Provider version bump to 3.74.x default. Support from 3.46.x to 3.74.x

ENHANCEMENTS:
* Encryption at Host enabled by default
    - add: encryption_at_host_enabled variable and default to true
* change: workload VM for greenfield deployments dns_servers to Azure DNS default
* add: AZURE_MANAGED_IDENTITY_CLIENT_ID field to userdata generation
* change: variable load_distribution set to Azure "Default" corresponding to None/5-tuple session persistency in the Azure Portal.
* change: name_prefix variable default to zscc

BUG FIXES:
* refactor: terraform-zscc-network-azure to remove data source read dependencies
* add: variable probe_threshold for [Azure LB health probe fixes](https://learn.microsoft.com/en-us/azure/load-balancer/whats-new#known-issues:~:text=February%202020-,Known%20issues,-The%20product%20group)


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
