## Required variables — populate before running terraform apply

#env_subscription_id          = ""
#cc_vm_managed_identity_name  = ""
#cc_vm_managed_identity_rg    = ""

## TF-AZ-10 (opt-in): create and assign a least-privilege Custom Role for the CC managed
## identity instead of relying on an out-of-band role assignment. See modules/terraform-zscc-identity-azure.
#create_cc_read_role          = true
#cc_read_role_name            = "cc-nic-read"
#cc_vm_prov_url               = ""
#azure_vault_url              = ""

## Optional overrides

#arm_location                 = "westus2"
#name_prefix                  = "zscc"
#network_address_space        = "10.1.0.0/16"
#cc_count                     = 2
#ccvm_instance_type           = "Standard_D2s_v3"
#ccvm_instance_type           = "Standard_DS2_v2"
#ccvm_instance_type           = "Standard_DS3_v2"
#ccvm_instance_type           = "Standard_D2ds_v5"
#ccvm_instance_type           = "Standard_D2ads_v5"
#http_probe_port              = 50000
#zones_enabled                = false
#zones                        = ["1"]
#reuse_nsg                    = false
#accelerated_networking_enabled = true
#encryption_at_host_enabled   = true
#support_access_enabled       = true

## BYO VNet — uncomment and populate to deploy into an existing VNet

#byo_rg                       = true
#byo_rg_name                  = "my-existing-rg"
#byo_vnet                     = true
#byo_vnet_name                = "my-existing-vnet"
#byo_subnets                  = true
#byo_subnet_names             = ["my-cc-subnet"]
#byo_vnet_subnets_rg_name     = "my-existing-rg"
