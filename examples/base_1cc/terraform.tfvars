## This is only a sample terraform.tfvars file.
## Uncomment and change the below variables according to your specific environment
#####################################################################################################################
##### Variables 1-12 are populated automically if terraform is ran via ZSEC bash script.   ##### 
##### Modifying the variables in this file will override any inputs from ZSEC              #####
#####################################################################################################################


#####################################################################################################################
##### Cloud Init Provisioning variables for userdata file  #####
#####################################################################################################################
## 1. Zscaler Cloud Connector Provisioning URL E.g. connector.zscaler.net/api/v1/provUrl?name=azure_prov_url

#cc_vm_prov_url                         = "connector.zscaler.net/api/v1/provUrl?name=azure_prov_url"

## 2. Azure Vault URL E.g. "https://zscaler-cc-demo.vault.azure.net"

#azure_vault_url                        =  "https://zscaler-cc-demo.vault.azure.net"

## 3. Cloud Connector cloud init provisioning listener port. This is required for Azure LB Health Probe deployments. 
## Uncomment and set custom probe port to a single value of 80 or any number between 1024-65535. Default is 0/null.

#http_probe_port                        = 50000

#####################################################################################################################
##### Prerequisite Provisioned Managed Identity Resource and Resource Group  #####
##### Managed Identity should have GET/LIST access to Key Vault Secrets and  #####
##### Network Contributor Role Assignment to Subscription or RG where Cloud  #####
##### Connectors will be provisioned prior to terraform deployment.          #####
##### (minimum Role permissions: Microsoft.Network/networkInterfaces/read)   ##### 
#####################################################################################################################


## 4. Provide the Azure Subscription ID where the User Managed Identity resides. This is only required if the
##    Managed Identity is in a different Subscription than the one where Cloud Connector is being deployed.
##    E.g "eab20328-8964-4168-a464-db4829164dc8"

#managed_identity_subscription_id       = "abc12345-6789-0123-a456-bc1234567de8"

## 5. Provide your existing Azure Managed Identity name to attach to the CC VM. E.g cloud_connector_managed_identity

#cc_vm_managed_identity_name            = "cloud_connector_managed_identity"

## 6. Provide the existing Resource Group of the Azure Managed Identity name to attach to the CC VM. E.g. cloud_connector_rg_1

#cc_vm_managed_identity_rg              = "cloud_connector_rg_1"


#####################################################################################################################
##### Custom variables. Only change if required for your environment  #####
#####################################################################################################################

## 7. Azure region where Cloud Connector resources will be deployed. This environment variable is automatically populated if running ZSEC script
##    and thus will override any value set here. Only uncomment and set this value if you are deploying terraform standalone. (Default: westus2)

#arm_location                           = "westus2"


## 8. Cloud Connector Azure VM Instance size selection. Uncomment ccvm_instance_type line with desired vm size to change.
##    (Default: Standard_D2s_v3)

#ccvm_instance_type                       = "Standard_D2s_v3"
#ccvm_instance_type                       = "Standard_DS3_v2"
#ccvm_instance_type                       = "Standard_D8s_v3"
#ccvm_instance_type                       = "Standard_D16s_v3"
#ccvm_instance_type                       = "Standard_DS5_v2"


## 9. Cloud Connector Instance size selection. Uncomment cc_instance_size line with desired vm size to change
##    (Default: "small") 
##    **** NOTE - There is a dependency between ccvm_instance_type and cc_instance_size selections ****
##    If size = "small" any supported Azure VM instance size can be deployed, but "Standard_D2s_v3" is ideal
##    If size = "medium" only Standard_DS3_v2/Standard_D8s_v3 and up Azure VM instance sizes can be deployed
##    If size = "large" only Standard_D16s_v3/Standard_DS5_v2 Azure VM instance sizes can be deployed 

#cc_instance_size                         = "small"
#cc_instance_size                         = "medium"
#cc_instance_size                         = "large" 


## 10. The number of Cloud Connector appliances to provision. Each incremental Cloud Connector will be created in alternating 
##    subnets based on the zones or byo_subnet_names variable and loop through for any deployments where cc_count > zones.
##    Not configurable for base or base_1cc deployment types. (All others - Default: 2)
##    E.g. cc_count set to 4 and 2 zones set ['1","2"] will create 2x CCs in AZ1 and 2x CCs in AZ2

#cc_count                               = 2


## 11. By default, no zones are specified in any resource creation meaning they are either auto-assigned by Azure 
##    (Virtual Machines and NAT Gateways) or Zone-Redundant (Public IP) based on whatever default configuration is.
##    Setting this value to true will do the following:
##    1. will create zonal NAT Gateway resources in order of the zones [1-3] specified in zones variable. 1x per zone
##    2. will NOT create availability set resource nor associate Cloud Connector VMs to one
##    3. will create zonal Cloud Connector Virtual Machine appliances looping through and alternating per the order of the zones 
##       [1-3] specified in the zones variable AND total number of Cloud Connectors specified in cc_count variable.
##    (Default: false)

#zones_enabled                          = true


## 12. By default, this variable is used as a count (1) for resource creation of Public IP, NAT Gateway, and CC Subnets.
##    This should only be modified if zones_enabled is also set to true
##    Doing so will change the default zone aware configuration for the 3 aforementioned resources with the values specified
##    
##    Use case: Define zone numbers "1" and "2". This will create 2x Public IPs (one in zone 1; the other in zone 2),
##              2x NAT Gateways (one in zone 1; the other in zone 2), associate the zone 1 PIP w/ zone 1 NAT GW and the zone 2
##              PIP w/ zone 2 NAT GW, create 2x CC Subnets and associate subnet 1 w/ zone 1 NAT GW and subnet 2 w/ zone 2 NAT GW,
##              then each CC created will be assigned a zone in the subnet corresponding to the same zone of the NAT GW and PIP associated.

##    Uncomment one of the desired zones configuration below.

#zones                                  = ["1"]
#zones                                  = ["1","2"]
#zones                                  = ["1","2","3"]


## 13. IPv4 CIDR configured with VNet creation. Workload, Public, and Cloud Connector Subnets will be created based off this prefix.
##    /24 subnets are created assuming this cidr is a /16. You may need to edit address_prefixes values for subnet creations if
##    desired for smaller or larger subnets. (Default: "10.1.0.0/16")

##    Note: This variable only applies if you let Terraform create a new VNet. Custom deployment with byo_vnet enabled will ignore this

#network_address_space                  = "10.1.0.0/16"


## 14. Cloud Connector Subnet space. (Minimum /28 required. Default: is null. If you do not specify subnets they will  
##    automatically be assigned based on the default cidrsubnet creation within from the VNet address space.
##    Uncomment and modify if byo_vnet is set to true AND you want terraform to create NEW subnets for Cloud Connector
##    in that existing VNET. OR if you choose to modify the address space in the newly created VNet via network_address_space variable change
##    CIDR and mask must be a valid value available within VNet.
##
##    ***** Note *****
##    It does not matter how many subnets you specify here. this script will only create 1 or as many as defined in the zones variable
##    Default/Minumum: 1 - Maximum: 3
##    Example: cc_subnets = ["10.1.150.0/24","10.1.151.0/24"]

#cc_subnets                             = ["10.1.150.0/24","10.1.151.0/24"]


## 15. Number of Workload VMs to be provisioned in the workload subnet. Only limitation is available IP space
##    in subnet configuration. Only applicable for "base" deployment types. Default workload subnet is /24 so 250 max

#workload_count                               = 2


## 16. Tag attribute "Owner" assigned to all resoure creation. (Default: "zscc-admin")

#owner_tag                              = "username@company.com"