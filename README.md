<a href="https://terraform.io">
    <img src="https://raw.githubusercontent.com/hashicorp/terraform-website/master/public/img/logo-text.svg" alt="Terraform logo" title="Terraform" height="50" width="250" />
</a>
<a href="https://www.zscaler.com/">
    <img src="https://www.zscaler.com/themes/custom/zscaler/logo.svg" alt="Zscaler logo" title="Zscaler" height="50" width="250" />
</a>

Zscaler Cloud Connector Azure Terraform Modules
===========================================================================================================

# **README for Azure Terraform**

This README serves as a quick start guide to deploy Zscaler Cloud Connector resources in Microsoft Azure using Terraform. To learn more about the resources created when deploying Cloud Connector with Terraform, see [Deployment Templates for Zscaler Cloud Connector](https://help.zscaler.com/cloud-connector/about-cloud-automation-scripts).

## **Azure Deployment Scripts for Terraform**

Use this repository to create the deployment resources required to deploy and operate Cloud Connector in a new or existing resource group and virtual network. The [examples directory](https://github.com/zscaler/terraform-aws-cloud-connector-modules/tree/main/examples) contains complete automation scripts for both greenfield/POV and brownfield/production use.

## **Prerequisites**

Our Deployment scripts are leveraging Terraform v1.1.9 which includes full binary and provider support for macOS M1 chips, but any Terraform version 0.13.7 should be generally supported.

- provider registry.terraform.io/hashicorp/azurerm v2.99.x
- provider registry.terraform.io/hashicorp/random v3.3.x
- provider registry.terraform.io/hashicorp/local v2.2.x
- provider registry.terraform.io/hashicorp/null v3.1.x
- provider registry.terraform.io/providers/hashicorp/tls v3.4.x

### **Azure Requirements**

1. Azure Subscription Id [link to Azure subscriptions](https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade)
2. Have/Create a Service Principal. See: [https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)). Then Collect:
  1. Application (client) ID
  2. Directory (tenant) ID
  3. Client Secret Value
3. Azure Region (e.g. westus2) where Cloud Connector resources are to be deployed
4. User-created Azure Managed Identity. Role Assignment: Network Contributor (If using a Custom Role, the minimum requirement is: Microsoft. Network/networkInterfaces/read) Scope: Subscription or Resource Group (where Cloud Connector VMs will be deployed)
5. Azure Vault URL with Zscaler Cloud Connector Credentials (E.g. [https://zscaler-cc-demo.vault.azure.net](https://zscaler-cc-demo.vault.azure.net/)) Add an access policy to the above Key Vault as below
  1. Secret Permissions: Get, List
  2. Select Principal: The Managed Identity created in the above step
6. Accept the Cloud Connector VM image terms for the Subscription(s) where Cloud Connector is to be deployed. This can be done via the Azure Portal, Cloud Shell or az cli / powershell with a valid admin user/service principal in the correct subscription where Cloud Connector is being deployed Run Command: `az vm image terms accept --urn zscaler1579058425289:zia_cloud_connector:zs_ser_gen1_cc_01:latest`

### **Zscaler requirements**

1. A valid Zscaler Cloud Connector provisioning URL generated. This is done via the Cloud Connector portal (E.g. connector..net/login)
2. Zscaler Cloud Connector Credentials (api key, username, password) are stored in Azure Key Vault from step 5.

## **Greenfield Deployments** 

### Use this if you are building an entire cluster from the ground up. These templates include a bastion host and test workloads and are designed for greenfield/POV testing.

### **Starter Deployment Template**

Use the [**Starter Deployment Template**](examples/base_1cc) to deploy your Cloud Connector in a new resource group and virtual network.

### **Starter Deployment Template with Load Balancer**

Use the [**Starter Deployment Template with Load Balancer**](examples/base_cc_lb) to deploy your Cloud Connector in a new resource group and virtual network and to load balance traffic across multiple Cloud Connectors. Zscaler's recommended deployment method is Azure Standard Load Balancer. Azure Load Balancer distributes traffic across multiple Cloud Connectors and achieves high availability.

## Brownfield Deployment

Brownfield deployment templates are most applicable for production deployments and have more customization options than a "base" deployment. They also do not include a bastion or workload hosts deployed. See [Modules](https://github.com/zscaler/terraform-azurerm-cloud-connector-modules/tree/main/modules) for the Terraform configurations for brownfield deployment.