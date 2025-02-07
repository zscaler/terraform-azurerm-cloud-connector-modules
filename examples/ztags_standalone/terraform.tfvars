## This is only a sample terraform.tfvars file.
## Uncomment and change the below variables according to your specific environment

#####################################################################################################################
##### Variables are populated automically if terraform is ran via ZSEC bash script.   ##### 
##### Modifying the variables in this file will override any inputs from ZSEC         #####
#####################################################################################################################

## 1. The name string for all Cloud Connector resources created by Terraform for Tag/Name attributes. (Default: zscc)

#name_prefix                                = "zstags"

## 2. The Zscaler registered PartnerDestination ID. 
##    e.g. /subscriptions/<subscriptionId>/resourceGroups/<partnerResourceGroup/providers/Microsoft.EventGrid/partnerDestinations/<partnerDestinationName>"

#partnerdestination_id                      = "fullPartnerId"

## 3. (Optional) Azure Subscription ID for Event Grid System Topic source property. If left null/commented out. 
#     resource will use caller subscription id. Only set if you are running terraform from a different subscription

#subscription_id                            = "subscription id"

## 4. (Optional) By default, Terraform will create a new Azure Resource Group. Event Grid resources will get placed in that RG.
##    Uncomment to use an existing Resource Group instead.

#existing_ztags_rg_name                     = "existingRg"

## 5. (Optional) Azure region where Cloud Connector resources will be deployed. This environment variable is automatically populated if running ZSEC script
##    and thus will override any value set here. Only uncomment and set this value if you are deploying terraform standalone. (Default: westus2)
##    Only required using this template to create a new Resource Group. 

#arm_location                               = "westus2"

## 6. Tag attribute "Owner" assigned to all resource created. (Default: "zscc-admin")

#owner_tag                                  = "username@company.com"

## 7. Tag attribute "Environment" assigned to all resources created. (Default: "Development")

#environment                                = "Development"
