## This is only a sample terraform.tfvars file.
## Uncomment and change the below variables according to your specific environment
#####################################################################################################################
##### Variables 1-17 are populated automically if terraform is ran via ZSEC bash script.   ##### 
##### Modifying the variables in this file will override any inputs from ZSEC              #####
#####################################################################################################################

##    Provide the Azure Subscription ID where Terraform will authenticate to via the azurerm provider.
##    ** Note ** This will be auto populated for you via ZSEC bash script, so only uncomment if running Terraform manually.
##    E.g "abc12345-6789-0123-a456-bc1234567de8"

#env_subscription_id                        = "abc12345-6789-0123-a456-bc1234567de8"

#####################################################################################################################
##### Cloud Init Provisioning variables for userdata file  #####
#####################################################################################################################
## 1. Zscaler Cloud Connector Provisioning URL E.g. connector.zscaler.net/api/v1/provUrl?name=azure_prov_url

#cc_vm_prov_url                             = "connector.zscaler.net/api/v1/provUrl?name=azure_prov_url"

## 2. Azure Vault URL E.g. "https://zscaler-cc-demo.vault.azure.net"

#azure_vault_url                            =  "https://zscaler-cc-demo.vault.azure.net"

## 3. Cloud Connector cloud init provisioning listener port. This is required for Azure LB Health Probe deployments. 
## Uncomment and set custom probe port to a single value of 80 or any number between 1024-65535. Default is 50000.

#http_probe_port                            = 50000

#####################################################################################################################
##### Prerequisite Provisioned Managed Identity Resource and Resource Group  #####
##### Managed Identity should have GET/LIST access to Key Vault Secrets and  #####
##### Network Contributor Role Assignment to Subscription or RG where Cloud  #####
##### Connectors will be provisioned prior to terraform deployment.          #####
##### (minimum Role permissions: Microsoft.Network/networkInterfaces/read)   ##### 
#####################################################################################################################

## 4. Provide the Azure Subscription ID where the User Managed Identity resides. Leave commented out unless the
##    Managed Identity is in a different Subscription than the one where Cloud Connector is being deployed.
##    E.g "eab20328-8964-4168-a464-db4829164dc8"

#managed_identity_subscription_id           = "abc12345-6789-0123-a456-bc1234567de8"

## 5. Provide your existing Azure Managed Identity name to attach to the CC VM. E.g cloud_connector_managed_identity

#cc_vm_managed_identity_name                = "cloud_connector_managed_identity"

## 6. Provide the existing Resource Group of the Azure Managed Identity name to attach to the CC VM. E.g. cloud_connector_rg_1

#cc_vm_managed_identity_rg                  = "cloud_connector_rg_1"


#####################################################################################################################
##### Custom variables. Only change if required for your environment  #####
#####################################################################################################################

## 7. Azure region where Cloud Connector resources will be deployed. This environment variable is automatically populated if running ZSEC script
##    and thus will override any value set here. Only uncomment and set this value if you are deploying terraform standalone. (Default: westus2)

#arm_location                               = "westus2"


## 8. Cloud Connector Azure VM Instance size selection. Uncomment ccvm_instance_type line with desired vm size to change.
##    (Default: Standard_D2s_v3)

#ccvm_instance_type                         = "Standard_D2s_v3"
#ccvm_instance_type                         = "Standard_DS3_v2"
#ccvm_instance_type                         = "Standard_D8s_v3"
#ccvm_instance_type                         = "Standard_D16s_v3"
#ccvm_instance_type                         = "Standard_DS5_v2"


## 9. Cloud Connector Instance size selection. Uncomment cc_instance_size line with desired vm size to change
##    (Default: "small") 
##    **** NOTE - There is a dependency between ccvm_instance_type and cc_instance_size selections ****
##    If size = "small" any supported Azure VM instance size can be deployed, but "Standard_D2s_v3" is ideal
##    If size = "medium" only Standard_DS3_v2/Standard_D8s_v3 and up Azure VM instance sizes can be deployed
##    If size = "large" only Standard_D16s_v3/Standard_DS5_v2 Azure VM instance sizes can be deployed 

#cc_instance_size                           = "small"
#cc_instance_size                           = "medium"
#cc_instance_size                           = "large" 


## 10. The number of Cloud Connector appliances to provision. Each incremental Cloud Connector will be created in alternating 
##    subnets based on the zones or byo_subnet_names variable and loop through for any deployments where cc_count > zones.
##    Not configurable for base or base_1cc deployment types. (All others - Default: 2)
##    E.g. cc_count set to 4 and 2 zones set ['1","2"] will create 2x CCs in AZ1 and 2x CCs in AZ2

#cc_count                                   = 2


## 11. By default, no zones are specified in any resource creation meaning they are either auto-assigned by Azure 
##    (Virtual Machines and NAT Gateways) or Zone-Redundant (Public IP) based on whatever default configuration is.
##    Setting this value to true will do the following:
##    1. will create zonal NAT Gateway resources in order of the zones [1-3] specified in zones variable. 1x per zone
##    2. will NOT create availability set resource nor associate Cloud Connector VMs to one
##    3. will create zonal Cloud Connector Virtual Machine appliances looping through and alternating per the order of the zones 
##       [1-3] specified in the zones variable AND total number of Cloud Connectors specified in cc_count variable.
##    (Default: false)

#zones_enabled                              = true


## 12. By default, this variable is used as a count (1) for resource creation of Public IP, NAT Gateway, and CC Subnets.
##    This should only be modified if zones_enabled is also set to true
##    Doing so will change the default zone aware configuration for the 3 aforementioned resources with the values specified
##    
##    Use case: Define zone numbers "1" and "2". This will create 2x Public IPs (one in zone 1; the other in zone 2),
##              2x NAT Gateways (one in zone 1; the other in zone 2), associate the zone 1 PIP w/ zone 1 NAT GW and the zone 2
##              PIP w/ zone 2 NAT GW, create 2x CC Subnets and associate subnet 1 w/ zone 1 NAT GW and subnet 2 w/ zone 2 NAT GW,
##              then each CC created will be assigned a zone in the subnet corresponding to the same zone of the NAT GW and PIP associated.

##    Uncomment one of the desired zones configuration below.

#zones                                      = ["1"]
#zones                                      = ["1","2"]
#zones                                      = ["1","2","3"]


## 13. Network Configuration:

##    IPv4 CIDR configured with VNet creation. All Subnet resources (Workload, Public, and Cloud Connector) will be created based off this prefix
##    /24 subnets are created assuming this cidr is a /16. If you require creating a VNet smaller than /16, you may need to explicitly define all other 
##     subnets via public_subnets, workload_subnets, and cc_subnets variables (Default: "10.1.0.0/16")

##    Note: This variable only applies if you let Terraform create a new VNet. Custom deployment with byo_vnet enabled will ignore this

#network_address_space                      = "10.1.0.0/16"

##    Subnet space. (Minimum /28 required. Default is null). If you do not specify subnets, they will automatically be assigned based on the default cidrsubnet
##    creation within the VNet address_prefix block. Uncomment and modify if byo_vnet is set to true but byo_subnets is left false meaning you want terraform to create 
##    NEW subnets in that existing VNet. OR if you choose to modify the network_address_space from the default /16 so a smaller CIDR, you may need to edit the below variables 
##    to accommodate that address space.

##    ***** Note *****
##    It does not matter how many subnets you specify here. this script will only create in order 1 or as many as defined in the zones variable
##    Default/Minumum: 1 - Maximum: 3
##    Example: If you change network_address_space to "10.2.0.0/24", set below variables to cidrs that fit in that /24 like cc_subnets = ["10.2.0.0/27","10.2.0.32/27"] etc.

#public_subnets                             = ["10.x.y.z/24","10.x.y.z/24"]
#workloads_subnets                          = ["10.x.y.z/24","10.x.y.z/24"]
#cc_subnets                                 = ["10.x.y.z/24","10.x.y.z/24"]
#private_dns_subnet                         = "10.x.y.z/28"


## 15. Tag attribute "Owner" assigned to all resoure creation. (Default: "zscc-admin")

#owner_tag                                  = "username@company.com"


## 16. Tag attribute "Environment" assigned to all resources created. (Default: "Development")

#environment                                = "Development"


## 17. By default, this script will apply 1 Network Security Group per Cloud Connector instance. 
##     Uncomment if you want to use the same Network Security Group for ALL Cloud Connectors (true or false. Default: false)

#reuse_nsg                                  = true

#####################################################################################################################
##### ZPA/Azure Private DNS specific variables #####
#####################################################################################################################
## 18. By default, ZPA dependent resources are not created. Uncomment if you want to enable ZPA configuration in your VNet
##     Enabling will create 1x dedicated/delegated DNS subnet with Route Tables pointing default route to the Azure
##     Load Balancer front-end IP. Module will also create a Private DNS Resolver, Ruleset, and rules per the domains
##     specified in variable "domain_names". (Default: false)

#zpa_enabled                                = true

## 19. Provide the domain names you want Azure Private DNS to redirect to Cloud Connector for ZPA interception. Only applicable for base + zpa or zpa_enabled = true
##     deployment types where Outbound DNS subnets, Resolver Ruleset/Rules, and Outbound Endpoints are being created. Two example domains are populated to show the 
##     mapping structure and syntax. ZPA Module will read through each to create a resolver rule per domain_name entry. Ucomment domain_names variable and
##     add any additional appsegXX mappings as needed.

#domain_names = {
#  appseg1 = "app1.com."
#  appseg2 = "app2.com."
#}

#####################################################################################################################
##### Custom BYO variables. Only applicable for "cc_lb" deployment without "base" resource requirements  #####
#####################################################################################################################

## 20. By default, this script will create a new Resource Group and place all resources in this group.
##     Uncomment if you want to deploy all resources in an existing Resource Group? (true or false. Default: false)

#byo_rg                                 = true


## 21. Provide your existing Resource Group name. Only uncomment and modify if you set byo_rg to true

#byo_rg_name                            = "existing-rg"


## 22. By default, this script will create a new Azure Virtual Network in the default resource group.
##     Uncomment if you want to deploy all resources to a VNet that already exists (true or false. Default: false)

#byo_vnet                               = true


## 23. Provide your existing VNet name. Only uncomment and modify if you set byo_vnet to true

#byo_vnet_name                          = "existing-vnet"


## 24. Provide the existing Resource Group name of your VNet. Only uncomment and modify if you set byo_vnet to true
##     Subnets depend on VNet so the same resource group is implied for subnets

#byo_vnet_subnets_rg_name               = "existing-vnet-rg"


## 25. By default, this script will create 1 new Azure subnet in the default resource group unles the zones variable
##     specifies multiple zonal deployments in which case subnet 1 would logically map to resources in zone "1", etc.
##     Uncomment if you want to deploy all resources in subnets that already exist (true or false. Default: false)
##     Dependencies require in order to reference existing subnets, the corresponding VNet must also already exist.
##     Setting byo_subnet to true means byo_vnet must ALSO be set to true.

#byo_subnets                            = true


## 26. Provide your existing Cloud Connector subnet names. Only uncomment and modify if you set byo_subnets to true
##     By default, management and service interfaces reside in a single subnet. Therefore, specifying multiple subnets
##     implies only that you are doing a zonal deployment with resources in separate AZs and corresponding zonal NAT
##     Gateway resources associated with the CC subnets mapped to the same respective zones.
##
##     Example: byo_subnet_names = ["subnet-az1","subnet-az2"]

#byo_subnet_names                       = ["existing-cc-subnet"]


## 27. By default, this script will create new Public IP resources to be associated with CC NAT Gateways.
##     Uncomment if you want to use your own public IP for the NAT GW (true or false. Default: false)

#byo_pips                               = true


## 28. Provide your existing Azure Public IP resource names. Only uncomment and modify if you set byo_pips to true
##     Existing Public IP resource cannot be associated with any resource other than an existing NAT Gateway in which
##     case existing_pip_association and existing_nat_gw_association need both set to true
##
##    ***** Note *****
##    If you already have existing PIPs AND set zone_enabled to true, these resource should be configured as zonal and
##    be added here to this variable list in order of the zones specified in the "zones" variable. 
##    Example: byo_pip_names = ["pip-az1","pip-az2"]

#byo_pip_names                          = ["pip-az1","pip-az2"]


## 29. Provide the existing Resource Group name of your Azure public IPs.  Only uncomment and modify if you set byo_pips to true

#byo_pip_rg                             = "existing-pip-rg"


## 30. By default, this script will create new NAT Gateway resources for the Cloud Connector subnets to be associated
##    Uncomment if you want to use your own NAT Gateway (true or false. Default: false)

#byo_nat_gws                            = true


## 31. Provide your existing Azure NAT Gateway resource names. Only uncomment and modify if you set byo_nat_gws to true
##    ***** Note *****
##    If you already have existing NAT Gateways AND set zone_enabled to true these resource should be configured as zonal and
##    be added here to this variable list in order of the zones specified in the "zones" variable. 
##    Example: byo_nat_gw_names  = ["natgw-az1","natgw-az2"]

#byo_nat_gw_names                       = ["natgw-az1","natgw-az2"]


## 32. Provide the existing Resource Group name of your NAT Gateway.  Only uncomment and modify if you set byo_nat_gws to true

#byo_nat_gw_rg                          = "existing-nat-gw-rg"


## 33.  By default, this script will create a new Azure Public IP and associate it with new/existing NAT Gateways.
##      Uncomment if you are deploying cloud connector to an environment where the PIP already exists AND is already asssociated to
##      an existing NAT Gateway. (true or false. Default: false). 
##      Setting existing_pip_association to true means byo_nat_gws and byo_pips must ALSO be set to true.

#existing_nat_gw_pip_association        = true


## 34.  By default this script will create a new Azure NAT Gateway and associate it with new or existing CC subnets.
##      Uncomment if you are deploying cloud connector to an environment where the subnet already exists AND is already asssociated to
##      an existing NAT Gateway. (true or false. Default: false). 
##      Setting existing_nat_gw_association to true means byo_subnets AND byo_nat_gws must also be set to true.

#existing_nat_gw_subnet_association     = true


## 35. By default, this script will create new Network Security Groups for the Cloud Connector mgmt and service interfaces
##     Uncomment if you want to use your own NSGs (true or false. Default: false)

#byo_nsg                                = true


## 36. Provide your existing Network Security Group resource names. Only uncomment and modify if you set byo_nsg to true
##     ***** Note *****

##    Example: byo_mgmt_nsg_names       = ["mgmt-nsg-1","mgmt-nsg-2"]
##    Example: byo_service_nsg_names    = ["service-nsg-1","service-nsg-2"]

#byo_mgmt_nsg_names                     = ["mgmt-nsg-1","mgmt-nsg-2"]
#byo_service_nsg_names                  = ["service-nsg-1","service-nsg-2"]


## 37. Provide the existing Resource Group name of your Network Security Groups.  Only uncomment and modify if you set byo_nsg to true

#byo_nsg_rg                             = "existing-nsg-rg"
