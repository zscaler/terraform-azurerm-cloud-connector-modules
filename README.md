# Zscaler Cloud Connector Azure Terraform Modules

## Description
This repository contains various modules and deployment configurations that can be used to deploy Zscaler Cloud Connector appliances to securely connect Workload to Internet and Workload to Workload communication within Microsoft Azure. The examples directory contains complete automation scripts for both greenfield/POV and brownfield/production use.

These deployment templates are intended to be fully functional and self service for both greenfield/pov as well as production use. All modules may also be utilized as design recommendation based on Zscaler's Official [Zero Trust Security for Azure Workloads Reference Architecture](https://help.zscaler.com/cloud-connector/zero-trust-security-azure-workloads-zscaler-cloud-connector).

## Prerequisites

Our Deployment scripts are leveraging Terraform v1.1.9 that includes full binary and provider support for MacOS M1 chips, but any Terraform version 0.13.7 should be generally supported.

- provider registry.terraform.io/hashicorp/azurerm v2.99.x
- provider registry.terraform.io/hashicorp/random v3.3.x
- provider registry.terraform.io/hashicorp/local v2.2.x
- provider registry.terraform.io/hashicorp/null v3.1.x
- provider registry.terraform.io/providers/hashicorp/tls v3.4.x

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

## How to deploy
Provisioning templates are available for customer use/reference to successfully deploy fully operational Cloud Connector appliances once the prerequisites have been completed. Please follow the instructions located in [examples](examples/README.md).

## Format

This repository follows the [Hashicorp Standard Modules Structure](https://www.terraform.io/registry/modules/publish):

* `modules` - All module resources utilized by and customized specifically for Cloud Connector deployments. The intent is these modules are resusable and functional for any deployment type referencing for both production or lab/testing purposes.
* `examples` - Zscaler provides fully functional deployment templates utilizing a combination of some or all of the modules published. These can utilized in there entirety or as reference templates for more advanced customers or custom deployments. For novice Terraform users, we also provide a bash script (zsec) that can be run from any Linux/Mac OS or CSP Cloud Shell that walks through all provisioning requirements as well as downloading/running an isolated teraform process. This allows Cloud Connector deployments from any supported client without having to even have Terraform installed or know how the language/syntax for running it.

## Versioning

These modules follow recommended release tagging in [Semantic Versioning](http://semver.org/). You can find each new release,
along with the changelog, on the GitHub [Releases](https://github.com/zscaler/terraform-aws-cloud-connector-modules/releases) page.
