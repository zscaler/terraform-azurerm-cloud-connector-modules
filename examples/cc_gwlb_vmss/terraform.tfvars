## Brownfield GWLB — sample terraform.tfvars
## Uncomment and set values according to your environment

#####################################################################################################################
##### Variables are populated automatically if terraform is run via ZSEC bash script.     #####
##### Modifying the variables in this file will override any inputs from ZSEC             #####
#####################################################################################################################

## 1. Azure Subscription ID where the GWLB resources will be deployed
##    E.g "abc12345-6789-0123-a456-bc1234567de8"

#env_subscription_id = "abc12345-6789-0123-a456-bc1234567de8"


#####################################################################################################################
##### Cloud Init Provisioning variables for userdata file  #####
#####################################################################################################################

## 2. Zscaler Cloud Connector Provisioning URL E.g. connector.zscaler.net/api/v1/provUrl?name=azure_prov_url

#cc_vm_prov_url = "connector.zscaler.net/api/v1/provUrl?name=azure_prov_url"

## 3. Azure Vault URL E.g. "https://zscaler-cc-demo.vault.azure.net"

#azure_vault_url = "https://zscaler-cc-demo.vault.azure.net"

## 4. Cloud Connector cloud init provisioning listener port. Default is 50000.

#http_probe_port = 50000


#####################################################################################################################
##### Prerequisite Provisioned Managed Identity Resource and Resource Group  #####
##### Managed Identity should have GET/LIST access to Key Vault Secrets and  #####
##### Network Contributor Role Assignment to Subscription or RG where Cloud  #####
##### Connectors will be provisioned prior to terraform deployment.          #####
#####################################################################################################################

## 5. Managed Identity subscription ID — only set if different from env_subscription_id

#managed_identity_subscription_id = "abc12345-6789-0123-a456-bc1234567de8"

## 6. Managed Identity name and resource group

#cc_vm_managed_identity_name = "cloud_connector_managed_identity"
#cc_vm_managed_identity_rg   = "cloud_connector_rg_1"


#####################################################################################################################
##### BYO (Bring Your Own) — existing infrastructure                                      #####
##### All resources below must already exist in Azure before running terraform apply      #####
#####################################################################################################################

## 7. Bring your own existing Resource Group (true or false. Default: false)

#byo_rg      = true
#byo_rg_name = "my-existing-cc-rg"

## 8. Bring your own existing VNet (true or false. Default: false)
##    byo_vnet_subnets_rg_name must also be set to the RG containing the VNet.

#byo_vnet                 = true
#byo_vnet_name            = "my-existing-vnet"
#byo_vnet_subnets_rg_name = "my-existing-rg"

## 9. Bring your own existing CC subnet(s) (true or false. Default: false)
##    byo_subnets = true requires byo_vnet = true as well.
##    Example: byo_subnet_names = ["subnet-az1","subnet-az2"]

#byo_subnets      = true
#byo_subnet_names = ["my-existing-cc-subnet"]


#####################################################################################################################
##### GWLB / VXLAN Configuration                                                          #####
##### Defaults match the SMEDGE edgeconnector image. Only change if your CC image        #####
##### was provisioned with non-default VXLAN values (verify with sc.network.conf).       #####
#####################################################################################################################

#vxlan_external_port = 10801
#vxlan_internal_port = 10800
#vxlan_external_vni  = 801
#vxlan_internal_vni  = 800
#http_probe_port     = 50000


#####################################################################################################################
##### Naming / Tags                                                                        #####
#####################################################################################################################

#name_prefix = "zscc"
#owner_tag   = "username@company.com"
#environment = "Production"


#####################################################################################################################
##### Availability Zones                                                                   #####
##### Recommended to match the zone(s) of the existing CC VMs                            #####
#####################################################################################################################

#zones_enabled = false
#zones         = ["1"]


#####################################################################################################################
##### Post-Apply: Chaining the GWLB to your existing Public Load Balancer (Consumer)     #####
#####                                                                                     #####
##### After terraform apply, take the gwlb_frontend_ip_config_id output value and        #####
##### attach it to your existing PLB frontend IP configuration:                           #####
#####                                                                                     #####
##### Portal:  PLB → Frontend IP configurations → Edit → Gateway Load Balancer dropdown  #####
##### CLI:     az network lb frontend-ip update \                                         #####
#####            --resource-group <rg> --lb-name <public_lb-name> --name <frontend-name> \#####
#####            --gateway-lb <gwlb_frontend_ip_config_id output>                        #####
#####################################################################################################################
