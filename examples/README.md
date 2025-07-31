# Zscaler Cloud Connector Cluster Infrastructure Setup

**Terraform configurations and modules for deploying Zscaler Cloud Connector Cluster in Azure.**

## Prerequisites (You will be prompted for Azure application credentials and region during deployment)

### **Azure Requirements**

1. Azure Subscription Id [link to Azure subscriptions](https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade)
2. Have/Create a Service Principal. See: [https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)). Then Collect:
    - Application (client) ID
    - Directory (tenant) ID
    - Client Secret Value
3. Azure Region (e.g. westus2) where Cloud Connector resources are to be deployed
4. User-created Azure Managed Identity. Role Assignment: Network Contributor (If using a Custom Role, the minimum requirement is: Microsoft. Network/networkInterfaces/read) Scope: Subscription or Resource Group (where Cloud Connector VMs will be deployed)
5. Azure Vault URL with Zscaler Cloud Connector Credentials (E.g. [https://zscaler-cc-demo.vault.azure.net](https://zscaler-cc-demo.vault.azure.net/)) Add an access policy to the above Key Vault as below
    - Secret Permissions: Get, List
    - Select Principal: The Managed Identity created in the above step
6. Accept the Cloud Connector VM image terms for the Subscription(s) where Cloud Connector is to be deployed. This can be done via the Azure Portal, Cloud Shell or az cli / powershell with a valid admin user/service principal in the correct subscription where Cloud Connector is being deployed Run Command: `az vm image terms accept --urn zscaler1579058425289:zia_cloud_connector:zs_ser_gen1_cc_01:latest`

### Terraform client requirements
7. If executing Terraform via the "zsec" wrapper bash script, it is advised that you run from a MacOS or Linux workstation. Minimum installed application requirements to successfully from the script are:
    - bash | curl | unzip | rm | cp | find | grep | sed | dig | jq (for vmss manual_sync script)

<p>These can all be installed via your distribution app installer. ie: sudo apt install bash curl unzip</p>

### **Zscaler requirements**

8. A valid Zscaler Cloud Connector provisioning URL generated. This is done via the Cloud Connector portal (E.g. connector..net/login)
9. Zscaler Cloud Connector Credentials (api key, username, password) are stored in Azure Key Vault from step 5.

See: [Zscaler Cloud Cloud Connector Azure Deployment Guide](https://help.zscaler.com/cloud-connector/deploying-cloud-connector-microsoft-azure) for additional prerequisite provisioning steps.

### *Host Disk Encryption*
To enable host encryption. You **must** subscribe to the feature on your azure account. Official Microsoft Documentation on how to enable this feature can be found [here](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-enable-host-based-encryption-portal?tabs=azure-cli#prerequisites)


## Deploying the cluster
(The automated tool can run only from MacOS and Linux. You can also upload all repo contents to the respective public cloud provider Cloud Shells and run directly from there).   
 
**1. Test/Greenfield Deployments**

(Use this if you are building an entire cluster from ground up.
 Particularly useful for a Customer Demo/PoC or dev-test environment)

```
bash
cd examples
Optional: Edit the terraform.tfvars file under your desired deployment type (ie: base_1cc) to setup your Cloud Connector (Details are documented inside the file)
- ./zsec up
- enter "1" for greenfield
- enter <desired deployment type>
- follow prompts for any additional configuration inputs. *keep in mind, any modifications done to terraform.tfvars first will override any inputs from the zsec script*
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm
```

**Test/Greenfield Deployment Types:**

```
Deployment Type: (base | base_1cc | base_1cc_zpa | base_cc_lb | base_cc_lb_zpa | base_cc_vmss | base_cc_vmss_zpa):
**base** - Creates: 1 Resource Group containing; 1 VNet w/ 2 subnets (bastion + workload); 1 Ubuntu server workload w/ 1 Network Interface + NSG; 1 Ubuntu Bastion Host w/ 1 PIP + 1 Network Interface + NSG; generates local key pair .pem file for ssh access. This does NOT deploy any actual Cloud Connectors.

**base_1cc** - Base deployment + Creates 1 Cloud Connector private subnet; 1 Cloud Connector VM in availability set routing to NAT Gateway; workload private subnet route repointed to the service interface IP of Cloud Connector

**base_1cc_zpa** - Everything from base_1cc + Creates Azure Private DNS Resolver, Private DNS Resolver Ruleset, Private DNS Resolver rules based on the number of domains entered, Virtual Network Link for Ruleset in the Cloud Connector VNet, and an Outbound Endpoint in a dedicated Outbound DNS subnet with custom UDR default route to CC.

**base_cc_lb** - Everything from base_1cc deployment + Creates 2 Cloud Connectors in availability set behind 1 Internal Azure Load Balancer; Number of Workload and Cloud Connectors deployed customizable within terraform.tfvars cc_count and vm_count variables

**base_cc_lb_zpa** - Everything from base_cc_lb + Creates Azure Private DNS Resolver, Private DNS Resolver Ruleset, Private DNS Resolver rules based on the number of domains entered, Virtual Network Link for Ruleset in the Cloud Connector VNet, and an Outbound Endpoint in a dedicated Outbound DNS subnet with custom UDR default route to CC LB VIP.

**base_cc_vmss** - Base deployment + Creates 1 or more Flexible Orchestration Virtual Machine Scale Sets (VMSS) and scaling policies for Cloud Connector in private subnet(s); and 1 function app for VMSS; Standard Azure Load Balancer; and workload private subnet UDR routing to the Load Balancer Frontend IP.

**base_cc_vmss_zpa** - Everything from base_cc_vmss + Creates Azure Private DNS Resolver, Private DNS Resolver Ruleset, Private DNS Resolver rules based on the number of domains entered, Virtual Network Link for Ruleset in the Cloud Connector VNet, and an Outbound Endpoint in a dedicated Outbound DNS subnet with custom UDR default route to CC LB VIP.
```

This deployment type is intended for greenfield/pov/lab purposes. It will deploy a fully functioning sandbox environment in a new Resource Group/VNet with test workload VMs. Full set of resources provisioned listed below; Effectively, this will create all network infrastructure dependencies for an Azure environment. Everything from "Base" deployment type ().<br>


**2. Prod/Brownfield Deployments**

(These templates would be most applicable for production deployments and have more customization options than a "base" deployments). They also do not include a bastion or workload hosts deployed.

```
bash
cd examples
Optional: Edit the terraform.tfvars file under your desired deployment type (ie: cc_lb) to setup your Cloud Connector (Details are documented inside the file)
- ./zsec up
- enter "2" for brownfield
- enter <desired deployment type>
- follow prompts for any additional configuration inputs. *keep in mind, any modifications done to terraform.tfvars first will override any inputs from the zsec script*
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm
```

**Prod/Brownfield Deployment Types**

```
Deployment Type: (cc_lb | cc_vmss):
**cc_lb** - Creates 1 Resource Group containing: 1 VNet w/ 1 CC subnet; 2 Cloud Connectors in availability set with 1 PIP; 1 NAT Gateway; Mgmt Network Interfaces + NSG, Service Network Interfaces + NSG; 1 Internal Azure LB; generates local key pair .pem file for ssh access. Number of Cloud Connectors deployed and ability to use existing resources (resource group(s), VNet/Subnets, PIP, NAT GW) customizable withing terraform.tfvars custom variables

**cc_vmss** - Creates a new Resource Group; 1 VNet; at least 1 Cloud Connector private subnet; at least 1 NAT Gateway with Public IP Address association to the Cloud Connector subnets; at least 1 Virtual Machine Scale Set (VMSS); and 1 function app for VMSS; generates local key pair .pem file for ssh access; 1 Standard Azure Load Balancer with all rules, probes, and NIC associations
```

<br>

Brownfield deployment types provide numerous customization options within terraform.tfvars to enable/disable bring-your-own resources for
Cloud Connector deployment in existing environments. Custom paramaters include: BYO existing Resource Group, PIPs, NAT Gateways and associations,
VNet, and subnets. Optional Azure Private DNS Resolver resource creation per variable zpa_enabled. The number of Cloud Connector VMs or Virtual Machine Scale Sets, Cloud Connector subnets, NAT Gateways, and Public IPs can vary based on if zones support is enabled and the amount of zone redundancy chosen.

**3. Standalone Deployments**

(These templates are most applicable for custom/specialized deployment configurations). No Cloud Connector resources are provisioned with this template as the dependency of this feature assumes the resources already exist.

```
bash
cd examples
Optional: Edit the terraform.tfvars file under your desired deployment type (ie: ztags_standalone) to manually set variable values (Details are documented inside the file)
- ./zsec up
- enter "3" for standalone ztags enablement
- follow prompts for any additional configuration inputs. *keep in mind, any modifications done to terraform.tfvars first will override any inputs from the zsec script*
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm
```

**Standalone Deployment Types**

```
Deployment Type: (ztags_standalone):
**ztags_standalone** - Creates a new Resource Group (or use an existing); Event Grid System Topic; and PartnerDestination Event Subscription for Zscaler Tag Discovery Service automation
```

## Destroying the cluster
```
cd examples
- ./zsec destroy
- verify all resources that will be destroyed and enter "yes" to confirm
```

## Notes
```
1. For auto approval set environment variable **AUTO_APPROVE** or add `export AUTO_APPROVE=1`
2. For deployment type set environment variable **dtype** to the required deployment type or add e.g. `export dtype=base_1cc`
3. To provide new credentials or region, delete the autogenerated .zsecrc file in your current working directory and re-run zsec.
```
