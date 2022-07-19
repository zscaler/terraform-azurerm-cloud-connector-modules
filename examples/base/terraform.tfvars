## This is only a sample terraform.tfvars file.
## Uncomment and change the below variables according to your specific environment
#####################################################################################################################
##### Custom variables. Only change if required for your environment  #####
#####################################################################################################################

## 1. Azure region where Cloud Connector resources will be deployed. This environment variable is automatically populated if running ZSEC script
##    and thus will override any value set here. Only uncomment and set this value if you are deploying terraform standalone. (Default: westus2)

#arm_location                           = "wesetus2"


## 2. IPv4 CIDR configured with VNet creation. Workload, Public, and Cloud Connector Subnets will be created based off this prefix.
##    /24 subnets are created assuming this cidr is a /16. You may need to edit address_prefixes values for subnet creations if
##    desired for smaller or larger subnets. (Default: "10.1.0.0/16")

##    Note: This variable only applies if you let Terraform create a new VNet. Custom deployment with byo_vnet enabled will ignore this

#network_address_space                  = "10.1.0.0/16"


## 3. Number of Workload VMs to be provisioned in the workload subnet. Only limitation is available IP space
##    in subnet configuration. Only applicable for "base" deployment types. Default workload subnet is /24 so 250 max

#vm_count                               = 2


## 4. Tag attribute "Owner" assigned to all resoure creation. (Default: "zscc-admin")

#owner_tag                              = "username@company.com"
