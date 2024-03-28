## This is only a sample terraform.tfvars file.
## Uncomment and change the below variables according to your specific environment

#####################################################################################################################
##### Variables are populated automically if terraform is ran via ZSEC bash script.   ##### 
##### Modifying the variables in this file will override any inputs from ZSEC         #####
#####################################################################################################################

## 1. Provide the Azure Subscription ID where Terraform will authenticate to via the azurerm provider.
##    ** Note ** This will be auto populated for you via ZSEC bash script, so only uncomment if running Terraform manually.
##    E.g "abc12345-6789-0123-a456-bc1234567de8"

#env_subscription_id                        = "abc12345-6789-0123-a456-bc1234567de8"

#####################################################################################################################
##### Cloud Init Provisioning variables for userdata file  #####
#####################################################################################################################

## 2. Zscaler Cloud Connector Provisioning URL E.g. connector.zscaler.net/api/v1/provUrl?name=azure_prov_url

#cc_vm_prov_url                             = "connector.zscaler.net/api/v1/provUrl?name=azure_prov_url"

## 3. Azure Vault URL E.g. "https://zscaler-cc-demo.vault.azure.net"

#azure_vault_url                            =  "https://zscaler-cc-demo.vault.azure.net"

## 4. Cloud Connector cloud init provisioning listener port. This is required for Azure LB Health Probe deployments. 
## Uncomment and set custom probe port to a single value of 80 or any number between 1024-65535. Default is 50000.

#http_probe_port                            = 50000

#####################################################################################################################
##### Prerequisite Provisioned Managed Identity Resource and Resource Group  #####
##### Managed Identity should have GET/LIST access to Key Vault Secrets and  #####
##### Network Contributor Role Assignment to Subscription or RG where Cloud  #####
##### Connectors will be provisioned prior to terraform deployment.          #####
##### (minimum Role permissions: Microsoft.Network/networkInterfaces/read)   ##### 
#####################################################################################################################

## 5. Provide the Azure Subscription ID where the User Managed Identity resides. Leave commented out unless the
##    Managed Identity is in a different Subscription than the one where Cloud Connector is being deployed.
##    E.g "abc12345-6789-0123-a456-bc1234567de8"

#managed_identity_subscription_id           = "abc12345-6789-0123-a456-bc1234567de8"

## 6. Provide your existing Azure Managed Identity name to attach to the CC VM. E.g cloud_connector_managed_identity

#cc_vm_managed_identity_name                = "cloud_connector_managed_identity"

## 7. Provide the existing Resource Group of the Azure Managed Identity name to attach to the CC VM. E.g. cloud_connector_rg_1

#cc_vm_managed_identity_rg                  = "cloud_connector_rg_1"


#####################################################################################################################
##### Custom variables. Only change if required for your environment  #####
#####################################################################################################################

## 8. The name string for all Cloud Connector resources created by Terraform for Tag/Name attributes. (Default: zscc)

#name_prefix                                = "zscc"

## 9. Azure region where Cloud Connector resources will be deployed. This environment variable is automatically populated if running ZSEC script
##    and thus will override any value set here. Only uncomment and set this value if you are deploying terraform standalone. (Default: westus2)

#arm_location                               = "westus2"

## 10. Cloud Connector Azure VM Instance size selection. Uncomment ccvm_instance_type line with desired vm size to change.
##    (Default: Standard_D2s_v3)

#ccvm_instance_type                         = "Standard_D2s_v3"
#ccvm_instance_type                         = "Standard_DS3_v2"
#ccvm_instance_type                         = "Standard_D8s_v3"
#ccvm_instance_type                         = "Standard_D16s_v3"
#ccvm_instance_type                         = "Standard_DS5_v2"

## 11. The number of Cloud Connector appliances to provision. Each incremental Cloud Connector will be created in alternating 
##    subnets based on the zones or byo_subnet_names variable and loop through for any deployments where cc_count > zones.
##    Not configurable for base or base_1cc deployment types. (All others - Default: 2)
##    E.g. cc_count set to 4 and 2 zones set ['1","2"] will create 2x CCs in AZ1 and 2x CCs in AZ2

#cc_count                                   = 2

## 12. By default, no zones are specified in any resource creation meaning they are either auto-assigned by Azure 
##    (Virtual Machines and NAT Gateways) or Zone-Redundant (Public IP) based on whatever default configuration is.
##    Setting this value to true will do the following:
##    1. will create zonal NAT Gateway resources in order of the zones [1-3] specified in zones variable. 1x per zone
##    2. will NOT create availability set resource nor associate Cloud Connector VMs to one
##    3. will create zonal Cloud Connector Virtual Machine appliances looping through and alternating per the order of the zones 
##       [1-3] specified in the zones variable AND total number of Cloud Connectors specified in cc_count variable.
##    (Default: false)

#zones_enabled                              = true

## 13. By default, this variable is used as a count (1) for resource creation of Public IP, NAT Gateway, and CC Subnets.
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

## 14. Network Configuration:

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

## 15. Number of Workload VMs to be provisioned in the workload subnet. Only limitation is available IP space
##    in subnet configuration. Only applicable for "base" deployment types. Default workload subnet is /24 so 250 max

#workload_count                             = 2

## 16. Tag attribute "Owner" assigned to all resoure creation. (Default: "zscc-admin")

#owner_tag                                  = "username@company.com"

## 17. Tag attribute "Environment" assigned to all resources created. (Default: "Development")

#environment                                = "Development"

## 18. By default, this script will apply 1 Network Security Group per Cloud Connector instance. 
##     Uncomment if you want to use the same Network Security Group for ALL Cloud Connectors (true or false. Default: false)

#reuse_nsg                                  = true

## 19. By default, Host encryption is enabled for Cloud Connector VMs. This does require the EncryptionAtHost feature
##     enabled for your subscription though first.
##     You can verify this by following the Azure Prerequisites guide here: 
##     https://learn.microsoft.com/en-us/azure/virtual-machines/linux/disks-enable-host-based-encryption-cli#prerequisites
##
##    Uncomment if you want to not enable this VM setting

#encryption_at_host_enabled                 = false

## 20. By default, if Terraform is creating NSGs an outbound rule named Zscaler_Support_Access is configured enabling 
##     Zscaler remote support access. Without this firewall access, Zscaler Support may not be able to assist as
##     efficiently if troubleshooting is required. Uncomment if you do not want to enable this rule. 
##
##     For more information, refer to: https://config.zscaler.com/zscaler.net/cloud-branch-connector and 
##     https://help.zscaler.com/cloud-branch-connector/enabling-remote-access

#support_access_enabled                     = false

## 21. By default, Terraform will lookup the latest Cloud Connector image version from the Azure Marketplace.
##     Uncomment and set this value to the path of a local subscription Microsoft.Compute image to override the 
##     Cloud Connector deployment with a private VHD instead of using the marketplace publisher.
##     *** This is recommended only for testing purposes and not supported for production deployments ***
##     Example: /subscriptions/<id>/resourceGroups/<rg>/providers/Microsoft.Compute/images/<image_name>

#ccvm_source_image_id                       = "<insert path to image>"


#####################################################################################################################
##### ZPA/Azure Private DNS specific variables #####
#####################################################################################################################
## 22. Provide the domain names you want Azure Private DNS to redirect to Cloud Connector for ZPA interception. 
##     Only applicable for base + zpa or zpa_enabled = true deployment types where Outbound DNS subnets, Resolver Ruleset/Rules, 
##     and Outbound Endpoints are being created. Two example domains are populated to show the mapping structure and syntax.
##     Azure does require a trailing dot "." on all domain entries. ZPA Module will read through each to create a resolver rule per 
##     domain_names entry. Ucomment domain_names variable and add any additional appsegXX mappings as needed.

#domain_names = {
#  appseg1 = "app1.com."
#  appseg2 = "app2.com."
#}

## 23. Azure Private DNS queries will be conditionally forwarded to these target IP addresses. Default are a pair of Zscaler Global VIP addresses.
##     The required expectation is that the target should follow VNet/subnet routing towards the configured Cloud Connector Load Balancer VIP for 
##     ZPA DNS interception

#target_address                             = ["185.46.212.88", "185.46.212.89"]
