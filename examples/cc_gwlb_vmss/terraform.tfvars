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
##### Prerequisite Provisioned Managed Identity Resource and Resource Group                                     #####
##### The Managed Identity should have GET/LIST access to Key Vault Secrets AND a least-privilege Custom Role   #####
##### that grants ONLY the permission Microsoft.Network/networkInterfaces/read, assigned at Resource Group      #####
##### scope (the RG where the Cloud Connector VMs will be deployed).                                            #####
##### Do NOT use the built-in Network Contributor role at Subscription scope. It grants write access to every   #####
##### NIC, NSG, route table, load balancer, and VNet peering across the entire subscription, far beyond what    #####
##### Cloud Connector requires at runtime. If a Custom Role cannot be created in your environment, Network      #####
##### Contributor scoped to the single Cloud Connector Resource Group is an acceptable (over-privileged)        #####
##### fallback.                                                                                                 #####
#####################################################################################################################

## 5. Managed Identity subscription ID — only set if different from env_subscription_id

#managed_identity_subscription_id = "abc12345-6789-0123-a456-bc1234567de8"

## 6. Managed Identity name and resource group

#cc_vm_managed_identity_name = "cloud_connector_managed_identity"
#cc_vm_managed_identity_rg   = "cloud_connector_rg_1"

## 6b. REQUIRED for VMSS deployments (TF-AZ-09): Function App autoscaler managed identity.
## This MUST reference a DIFFERENT User-Assigned Managed Identity than cc_vm_managed_identity_*
## above. The Function App needs VMSS Compute write/delete and Key Vault secret-read; the CC
## VMs do not. Sharing one identity means a compromised CC VM inherits the autoscaler's power
## to delete sibling CCs and read every Zscaler provisioning secret.
## Terraform plan will FAIL with a TF-AZ-09 error if these are empty or match the CC identity.

function_app_managed_identity_name = ""
function_app_managed_identity_rg   = ""

## TF-AZ-09/TF-AZ-10 (opt-in): create and assign least-privilege Custom Roles for the CC
## and/or Function App managed identities instead of relying on out-of-band role assignments.
## See modules/terraform-zscc-identity-azure. Key Vault Secrets User is Azure RBAC and only
## takes effect if the target vault has enable_rbac_authorization = true.
#create_cc_read_role      = true
#cc_read_role_name        = "cc-nic-read"
#create_function_app_role = true
#function_app_role_name   = "function-app-vmss-ops"


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
