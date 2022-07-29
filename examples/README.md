# Zscaler Cloud Connector Cluster Infrastructure Setup

**Terraform configurations and modules for deploying Zscaler Cloud Connector Cluster in Azure.**

## Prerequisites (You will be prompted for Azure application credentials and region during deployment)

### Azure Requirements
1. Azure Subscription Id
[link to Azure subscriptions](https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade)
2. Have/Create a Service Principal. See: https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal). Then Collect:
   1. Application (client) ID
   2. Directory (tenant) ID
   3. Client Secret Value
3. Azure Region (e.g. westus2) where Cloud Connector resources are to be deployed
4. User created Azure Managed Identity.
    Role Assignment:  Network Contributor (If using a Custom Role, the minimum requirement is: Microsoft.Network/networkInterfaces/read)
    Scope: Subscription or Resource Group (where Cloud Connector VMs will be deployed)
5. Azure Vault URL with Zscaler Cloud Connector Credentials (E.g. https://zscaler-cc-demo.vault.azure.net)
   Add an access policy to the above Key Vault as below
   1. Secret Permissions: Get, List
   2. Select Principal: The Managed Identity created in the above step
6. Accept the Cloud Connector VM image terms for the Subscription(s) where Cloud Connector is to be deployed. This can be done via the Azure Portal, Cloud Shell or az cli / powershell with a valid admin user/service principal in the correct subscription where Cloud Connector is being deployed
    Run Command: az vm image terms accept --urn zscaler1579058425289:zia_cloud_connector:zs_ser_gen1_cc_01:latest

### Zscaler requirements
7. A valid Zscaler Cloud Connector provisioning URL generated. This is done via the Cloud Connector portal (E.g. connector.<zscalercloud>.net/login)
8. Zscaler Cloud Connector Credentials (api key, username, password) are stored in Azure Key Vault from step 5.

See: [Zscaler Cloud Cloud Connector Azure Deployment Guide](https://help.zscaler.com/cloud-connector/deploying-cloud-connector-microsoft-azure) for additional prerequisite provisioning steps.


## Deploying the cluster
(The automated tool can run only from MacOS and Linux. You can also upload all repo contents to the respective public cloud provider Cloud Shells and run directly from there).   
 
**1. Greenfield Deployments**

(Use this if you are building an entire cluster from ground up.
 Particularly useful for a Customer Demo/PoC or dev-test environment)

```
bash
cd examples
Optional: Edit the terraform.tfvars file under your desired deployment type (ie: base_1cc) to setup your Cloud Connector (Details are documented inside the file)
- ./zsec up
- enter "greenfield"
- enter <desired deployment type>
- follow prompts for any additional configuration inputs. *keep in mind, any modifications done to terraform.tfvars first will override any inputs from the zsec script*
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm
```

**Greenfield Deployment Types:**

```
Deployment Type: (base | base_cc | base_cc_lb ):
**base** - Creates: 1 Resource Group containing; 1 VNet w/ 2 subnets (bastion + workload); 1 Ubuntu server workload w/ 1 Network Interface + NSG; 1 Ubuntu Bastion Host w/ 1 PIP + 1 Network Interface + NSG; generates local key pair .pem file for ssh access

**base_cc** - Base deployment + Creates 1 Cloud Connector private subnet; 1 Cloud Connector VM in availability set routing to NAT Gateway; workload private subnet route repointed to the service interface IP of Cloud Connector

**base_cc_lb** - Everything from base_cc deployment + Creates 2 Cloud Connectors in availability set behind 1 Internal Azure Load Balancer; Number of Workload and Cloud Connectors deployed customizable within terraform.tfvars cc_count and vm_count variables
```


**2. Brownfield Deployments**

(These templates would be most applicable for production deployments and have more customization options than a "base" deployments)

```
bash
cd examples
Optional: Edit the terraform.tfvars file under your desired deployment type (ie: cc_lb) to setup your Cloud Connector (Details are documented inside the file)
- ./zsec up
- enter "brownfield"
- enter <desired deployment type>
- follow prompts for any additional configuration inputs. *keep in mind, any modifications done to terraform.tfvars first will override any inputs from the zsec script*
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm
```

**Brownfield Deployment Types**

```
Deployment Type: (cc_lb_custom):
**cc_lb_custom** - Creates 1 Resource Group containing: 1 VNet w/ 1 CC subnet; 2 Cloud Connectors in availability set with 1 PIP; 1 NAT Gateway; Mgmt Network Interfaces + NSG, Service Network Interfaces + NSG; 1 Internal Azure LB; generates local key pair .pem file for ssh access. Number of Cloud Connectors deployed and ability to use existing resources (resource group(s), VNet/Subnets, PIP, NAT GW) customizable withing terraform.tfvars custom variables

Deployment type cc_lb_custom provides numerous customization options within terraform.tfvars to enable/disable bring-your-own resources for
Cloud Connector deployment in existing environments. Custom paramaters include: BYO existing Resource Group, PIPs, NAT Gateways and associations,
VNet, and subnets
```

## Destroying the cluster
```
cd examples
- ./zsec destroy
- enter "brownfield" or "greenfield" based on your original creation/up selection
- enter "deployment type" from original creation/up selection
- verify all resources that will be destroyed and enter "yes" to confirm
```

## Notes
```
1. For auto approval set environment variable **AUTO_APPROVE** or add `export AUTO_APPROVE=1`
2. For deployment type set environment variable **DTYPE** to the required deployment type or add e.g. `export DTYPE=base_1cc`
3. To provide new credentials or region, delete the autogenerated .zsecrc file in your current working directory and re-run zsec.
```