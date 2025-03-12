# Zscaler "Base_cc_vmss_zpa" deployment type

This deployment type is intended for greenfield/pov/lab purposes. It will deploy a fully functioning sandbox environment in a new Resource Group/VNet with test workload VMs. Full set of resources provisioned listed below; Effectively, this will create all network infrastructure dependencies for an Azure environment. Everything from "Base" deployment type (Creates 1 new Resource Group; 1 VNet with 1 public subnet and 1 private/workload subnet; 1 test workload in the private subnet; 1 Bastion Host in the public subnet assigned a Public IP; and generates local key pair .pem file for ssh access).<br>

Additionally: Depending on the configuration, creates 1 or more Flexible Orchestration Virtual Machine Scale Sets (VMSS) and scaling policies for Cloud Connector in private subnet(s); and 1 function app for VMSS; Standard Azure Load Balancer; workload private subnet UDR routing to the Load Balancer Frontend IP; Private DNS Resolver, Private DNS Resolver Ruleset, Private DNS Resolver rules based on the number of domains entered, Virtual Network Link for Ruleset, and Outbound Endpoint in a dedicated Outbound DNS subnet.

## Terraform client requirements
If run_manual_sync variable is True (True by default) the bash script scripts/manual_sync.sh is invoked to perform this manual sync (more information in the Caveates section), it is advised that you run from a MacOS or Linux workstation and have the following tools installed:
    - bash | curl | jq

## Caveats/Considerations
- WSL2 DNS bug: If you are trying to run these Azure terraform deployments specifically from a Windows WSL2 instance like Ubuntu and receive an error containing a message similar to this "dial tcp: lookup management.azure.com on 172.21.240.1:53: cannot unmarshal DNS message" please refer here for a WSL2 resolv.conf fix. https://github.com/microsoft/WSL/issues/5420#issuecomment-646479747.
- Function App Manual Sync: On creation time of the Function App, used for managing Cloud Connectors in the Scale Set, Azure requires that a "Manual Sync" operation is done. This can be done through an API call or through simply navigating to the Function App on the Azure console and having the page load. This action will tell the Function App to load the zip file from the Storage Account and start running the Functions. We have attemped to automate this Manual Sync call through terraform by triggering scripts/manual_sync.sh through a provisioner in the Function App Terraform module. If this attempt fails an output message (shown below) will be displayed in the testbed.txt and printed to the screen at the end of the deployment. If the Manual Sync operation fails during terraform apply, the steps listed in the message can be used to remediate the issue. This is a one time action at Function App creation time.
```
**IMPORTANT (ONLY APPLICABLE FOR INITIAL CREATE OF FUNCTION APP)**
Based on the recorded output, the manual sync to start your Azure Function App failed. To perform this manual sync perform one of the following steps:
  1. Navigate to the Azure Function App /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Web/sites/<function-app> on the Azure Portal. The loading of the Function App page triggers the manual sync and will start your Function App.
  2. Attempt to rerun the manual_sync.sh script manually using the following command (path to file is based on root of the repo):
      ../../modules/terraform-zscc-function-app-azure/manual_sync.sh <subscription-id> <resource-group> <function-app>
**IMPORTANT (ONLY APPLICABLE FOR INITIAL CREATE OF FUNCTION APP)**
```

## Components
![VMSS Topology drawio (8)](https://github.com/user-attachments/assets/8f8edea3-f6dd-41d1-aa88-29511e8d0c12)

### Topology Details
- Security Stack will be deployed into its own Resource Group.
- Based on zonal needs, a VMSS will be created in each configured zone.
- An Azure Internal Load Balancer (ILB) is deployed on top of all the Scale Sets and is used as the entry point for the Security Stack.
- A NAT Gateway will be deployed in each configured zone and will have a dedicated IP associated with it, this will be used for outbound traffic from the Cloud Connectors.

It is recommended that this security stack is deployed into its own VNet (Security VNet) and Workload VNets are peered with it. Once the security stack is deployed, route tables in the Workload VNets should have a User Defined Route steering traffic to the ILB sitting on top of the Cloud Connectors.

### Azure Function App
The Azure Function App will contain two Azure Functions.
1. Health Monitoring Function - Responsible for using the custom metrics published by each CC to determine if there are any unhealthy CCs that need to be replaced. If a CC is found to be unhealthy, the function will terminate the instance and will replace it with a new one. This function will run every one minute.
2. Resource Sync Function - Responsible for ensuring the VMs advertised in your Cloud Connector Group on the Zscaler Cloud Connector Portal match what is existing in your Azure Scale Set. If it finds that a CC exists in the Cloud Connector Group but not in the Azure Scale Set, it will perform the clean up of that instance from the Cloud Connector Group to ensure the two entities are in sync. This function will every every 30 minutes.

## How to deploy:

### Option 1 (guided):
From the examples directory, run the zsec bash script that walks to all required inputs.
- ./zsec up
- enter "greenfield"
- enter "base_cc_vmss_zpa"
- follow the remainder of the authentication and configuration input prompts.
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm

### Option 2 (manual):
Modify/populate any required variable input values in base_cc_vmss_zpa/terraform.tfvars file and save.

From base_cc_vmss_zpa directory execute:
- terraform init
- terraform apply

## How to destroy:

### Option 1 (guided):
From the examples directory, run the zsec bash script that walks to all required inputs.
- ./zsec destroy

### Option 2 (manual):
From base_cc_vmss_zpa directory execute:
- terraform destroy


#### ZSEC Configuration
Configure the following options:
```
Cloud Connector User Managed Identity Information:
Is the Managed Identity in the same Subscription ID? [yes/no]: yes
Managed Identity is in the same Subscription
Enter Managed Identity Name: <cc-managed-identity-name>
Enter Managed Identity Resource Group: <cc-managed-identity-resource-group>
Function App User Managed Identity Information:
Assign the same User Managed Identity (<cc-managed-identity-name>) to Function App? [yes/no]: no
Enter Function App designated Managed Identity Name: <function-app-managed-identity-name>
Enter Function App designated Managed Identity Resource Group: <function-app-managed-identity-resource-group>
```

### Scheduled Scaling
- Enables you to redefine minimum Cloud Connectors in Scale Set for specific time periods.
- Should be used if you have predictable traffic patterns (9am-5pm Monday-Friday).

#### Terraform Configuration
Setting the following variables:
```
scheduled_scaling_enabled         = true
scheduled_scaling_vmss_min_ccs    = 3
scheduled_scaling_days_of_week    = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
scheduled_scaling_start_time_hour = 7
scheduled_scaling_start_time_min  = 30
scheduled_scaling_end_time_hour   = 18
scheduled_scaling_end_time_min    = 30
```

#### ZSEC Configuration
Configure the following options:
```
Do you want to enable scheduled scaling on the VMSS? [yes/no]: yes
Enter the minimum amount of scheduled Cloud Connectors in VMSS? [Default=2]: 3
Apply Scheduled Scaling Policy on Sunday? [yes/no]: no
Not configuring Sunday on Scheduled Scaling configuration.
Apply Scheduled Scaling Policy on Monday? [yes/no]: yes
Adding Monday on Scheduled Scaling configuration.
Apply Scheduled Scaling Policy on Tuesday? [yes/no]: yes
Adding Tuesday on Scheduled Scaling configuration.
Apply Scheduled Scaling Policy on Wednesday? [yes/no]: yes
Adding Wednesday on Scheduled Scaling configuration.
Apply Scheduled Scaling Policy on Thursday? [yes/no]: yes
Adding Thursday on Scheduled Scaling configuration.
Apply Scheduled Scaling Policy on Friday? [yes/no]: yes
Adding Friday on Scheduled Scaling configuration.
Apply Scheduled Scaling Policy on Saturday? [yes/no]: no 
Not configuring Saturday on Scheduled Scaling configuration.
Configuring the following days on the Scheduled Scaling Policy: Monday Tuesday Wednesday Thursday Friday 
Enter the start time hour for the scheduled scaling configuration? [Default=9]: 7
Enter the start time min for the scheduled scaling configuration? [Default=0]: 30
Enter the end time hour for the scheduled scaling configuration? [Default=17]: 18
Enter the end time min for the scheduled scaling configuration? [Default=30]: 30
```

## Debugging Tips

### Viewing Cloud Connector Health Metrics
Cloud Connector Health metrics are published every 1 minute by the Cloud Connector and are managed by Application Insights. One easy way to view the metrics is to navigate to one of the running instances: Resource Group -> Scale Set -> Instances (tab on left) -> select instance -> Metrics (tab on left). Next create a metric query where:
- Scope = vm-name
- Metric Namespace = zscaler/cloudconnectors
- Metric = cloud_connector_aggr_health
- Aggregation = average
![Screenshot 2024-07-23 at 2 16 52 PM](https://github.com/user-attachments/assets/9b19b300-437a-4c9c-ab19-46d8f34688a0)

### Viewing Virtual Machine Scale Set Scaling Metrics
Cloud Connectors in a Scale Set publish scaling metrics to the Scale Set resource once a minute. These scaling metrics include smedge_cpu_utilization, smedge_mem_utilization, smedge_bytes_in and smedge_bytes_out. The scaling rules in the Scale Set scaling configuration will look at the smedge_cpu_utilization and compare it to the defined threshold.

To view these metrics navigate to the Scale Set you are interested in: Resource Group -> select Scale Set -> Metrics (tab on left). Next create a metrics query where:
- Scope = scale-set-name
- Metric Namespace = zscaler/cloudconnectors
- Metric = smedge_metrics
- Aggregation = average

Lastly, create a filter where:
- metric_name = smedge_cpu_utilization
![Screenshot 2024-07-23 at 2 16 25 PM](https://github.com/user-attachments/assets/7946ab64-0585-4c7c-b56a-f4a2bd472d57)

### Viewing Function App Logs
There are a couple approaches for viewing logs from a Function inside a Function App.
#### Recent Invocations
To view recent invocations you can navigate to the function you are interested in: Resource Group -> select Function App -> select Function (shown on overview page) -> Invocations
![Screenshot 2024-07-23 at 2 36 37 PM](https://github.com/user-attachments/assets/9809394f-98da-4e86-ba7a-14a3bd8aef8b)

#### Real Time Log Steaming
To view real time logs from function executing at that time you can navigate to the function you interested in: Resource Group -> select Function App -> select Function (shown on overview page) -> Logs
![Screenshot 2024-07-23 at 2 30 56 PM](https://github.com/user-attachments/assets/93e7f32a-c07f-4f7e-bc3c-737376803fc3)

#### Viewing through Application Insights
The more complex but powerful approach for viewing logs would be to use Application Insights. Application Insights will give you the ability to perform queries to view specific log messages, executions, timeframes, etc. One basic example of viewing logs from the Health Monitor function where it has found no instances need to be terminated. You can see that a specific message is defined when querying the logs, this will allow you to refine your search instead of manually going through each invocation or continuously watching the real time streaming.

Navigate to: Resource Group -> Application Insights -> Logs (tab on left)
Use the following query:
```
union traces
| union exceptions
| where timestamp > ago(1d)
| where customDimensions['Category'] == 'Function.healthMonitor.User' or customDimensions['Category'] == 'Function.healthMonitor'
| where message contains "No instances to terminate on this iteration."
| order by timestamp asc
| project
    timestamp,
    message = iff(message != '', message, iff(innermostMessage != '', innermostMessage, customDimensions.['prop__{OriginalFormat}']))
```
![Screenshot 2024-07-23 at 2 47 42 PM](https://github.com/user-attachments/assets/feeb3850-fa80-4f6a-9996-cfa8f69b59f0)

## FAQs

### When is a Cloud Connector considered to be unhealthy and should be replaced?
Each Cloud Connector will broadcast its health to the Azure Application Insights Instance in the Resource Group (to view these metrics refer to Debugging Tips->Viewing Cloud Connector Health Metrics). The health relates to the dataplanes health and correlates to the active/inactive state you will in the Cloud Connetor Group on the Zscaler Connector Portal. This health is evaluated by a process in the Cloud Connector and a value is published to this metric every 1 minute, 0 indicates unhealthy and 100 indicates healthy. An instance should be replaced in one of the two scenarios:
1. The Cloud Connector reports unhealty 5 times in a row. This indicates the Cloud Connector is down and should be replaced.
2. The Cloud Connector reports unhealthy 7 out of 10 times. This indicates the Cloud Connector is flapping and should be replaced.

The Health Monitoring Function in the Function App will perform this evaluation every 1 minute and will determine if any instances should be replaced. When an instance is replaced, it will be terminated and the Health Monitoring Function will ensure a new one is brought up to replace it.

### I am seeing unhealthy instance not being replaced in my Scale Set, what could be the issue?
In this scenario you should first check to see if the metrics published by the unhealthy instance are of value 0, this indicated unhealthy (100 indicates healthy). Please refer to the Debugging Tips->Viewing Cloud Connector Health Metrics section. If you are seeing the value of this metric at 0 for a long period of time (refer to FAQs->When is a Cloud Connector considered to be unhealthy and should be replaced?), the next thing you should check is to see if the Function App is running. During creation of the Function App, there is a manual sync trigger that needs to be successfully invoked for the Function App to start (refer to Caveats/Considerations->Function App Manual Sync), if the Function App is not running the unhealthy instances will not be replaced. Navigate to the Function App on the Azure Console to invoke the Manual Sync and view the invocations (Debugging Tips->Viewing Function App Logs->Recent Invocations) to see if it has been running.

### How can I stop the Health Monitoring Function from terminating unhealthy instances?
This can be configured through modifying the following terraform variable and then applying the change:
```
terminate_unhealthy_instances = false
```
It can also be configured manually on Azure Portal by navigating to the environment variables of the Function App: Resource Group -> select Function App -> Environment variables. Then selecting TERMINATE_UNHEALTHY_INSTANCES and setting the value to false. Once this is done apply the change.
![Screenshot 2024-07-23 at 2 50 58 PM](https://github.com/user-attachments/assets/a01e2c46-61e2-4959-bf7f-a668db1a2967)

### Can I just use one Managed Identity for both the Cloud Connectors and Azure Function App?
Yes, this can be done with terraform by not setting the following variables: function_app_managed_identity_name and function_app_managed_identity_rg.

### How can I find the Mgmt IP address of a Cloud Connector in a Scale Set?
Mgmt IP address will not be printed after the terraform executes because the dynamic nature of a Scale Set results in us not know what the IP address is. Therefore if you wish to SSH into one of the Cloud Connectors you will need to find the instance you are interested in on the Azure Portal to get the IP address to use for the connection. 

To find this Mgmt IP navigate to: Resource Group -> select Scale Set -> Instances (tab on left) -> select Instance -> Network Settings (tab on left). Once here you can check to make sure you are looking at the mgmt interface. This can be confirmed by seeing “mgmt” in the interface name. From there you can copy the IP address.
![Screenshot 2024-07-23 at 2 59 50 PM](https://github.com/user-attachments/assets/4da74652-26aa-4e39-a82e-5517a476e765)


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.108.0, <= 3.116 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.108.0, <= 3.116 |
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.3.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 3.4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ../../modules/terraform-zscc-bastion-azure | n/a |
| <a name="module_cc_functionapp"></a> [cc\_functionapp](#module\_cc\_functionapp) | ../../modules/terraform-zscc-function-app-azure | n/a |
| <a name="module_cc_identity"></a> [cc\_identity](#module\_cc\_identity) | ../../modules/terraform-zscc-identity-azure | n/a |
| <a name="module_cc_lb"></a> [cc\_lb](#module\_cc\_lb) | ../../modules/terraform-zscc-lb-azure | n/a |
| <a name="module_cc_nsg"></a> [cc\_nsg](#module\_cc\_nsg) | ../../modules/terraform-zscc-nsg-azure | n/a |
| <a name="module_cc_vmss"></a> [cc\_vmss](#module\_cc\_vmss) | ../../modules/terraform-zscc-ccvmss-azure | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../modules/terraform-zscc-network-azure | n/a |
| <a name="module_private_dns"></a> [private\_dns](#module\_private\_dns) | ../../modules/terraform-zscc-private-dns-azure | n/a |
| <a name="module_workload"></a> [workload](#module\_workload) | ../../modules/terraform-zscc-workload-azure | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_resolver_virtual_network_link.dns_vnet_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_virtual_network_link) | resource |
| [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.ssh_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.testbed](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.user_data_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerated_networking_enabled"></a> [accelerated\_networking\_enabled](#input\_accelerated\_networking\_enabled) | Enable/Disable accelerated networking support on all Cloud Connector service interfaces | `bool` | `true` | no |
| <a name="input_arm_location"></a> [arm\_location](#input\_arm\_location) | The Azure Region where resources are to be deployed | `string` | `"westus2"` | no |
| <a name="input_asp_sku_name"></a> [asp\_sku\_name](#input\_asp\_sku\_name) | SKU Name for the App Service Plan. Recommended Y1 (flex consumption) for function app unless not supported by Azure region | `string` | `"Y1"` | no |
| <a name="input_azure_vault_url"></a> [azure\_vault\_url](#input\_azure\_vault\_url) | Azure Vault URL | `string` | n/a | yes |
| <a name="input_bastion_nsg_source_prefix"></a> [bastion\_nsg\_source\_prefix](#input\_bastion\_nsg\_source\_prefix) | user input for locking down SSH access to bastion to a specific IP or CIDR range | `string` | `"*"` | no |
| <a name="input_cc_subnets"></a> [cc\_subnets](#input\_cc\_subnets) | Cloud Connector Subnets to create in VNet. This is only required if you want to override the default subnets that this code creates via network\_address\_space variable. | `list(string)` | `null` | no |
| <a name="input_cc_vm_managed_identity_name"></a> [cc\_vm\_managed\_identity\_name](#input\_cc\_vm\_managed\_identity\_name) | Azure Managed Identity name to attach to the CC VM. E.g zspreview-66117-mi | `string` | n/a | yes |
| <a name="input_cc_vm_managed_identity_rg"></a> [cc\_vm\_managed\_identity\_rg](#input\_cc\_vm\_managed\_identity\_rg) | Resource Group of the Azure Managed Identity name to attach to the CC VM. E.g. edgeconnector\_rg\_1 | `string` | n/a | yes |
| <a name="input_cc_vm_prov_url"></a> [cc\_vm\_prov\_url](#input\_cc\_vm\_prov\_url) | Zscaler Cloud Connector Provisioning URL | `string` | n/a | yes |
| <a name="input_ccvm_image_offer"></a> [ccvm\_image\_offer](#input\_ccvm\_image\_offer) | Azure Marketplace Cloud Connector Image Offer | `string` | `"zia_cloud_connector"` | no |
| <a name="input_ccvm_image_publisher"></a> [ccvm\_image\_publisher](#input\_ccvm\_image\_publisher) | Azure Marketplace Cloud Connector Image Publisher | `string` | `"zscaler1579058425289"` | no |
| <a name="input_ccvm_image_sku"></a> [ccvm\_image\_sku](#input\_ccvm\_image\_sku) | Azure Marketplace Cloud Connector Image SKU | `string` | `"zs_ser_gen1_cc_01"` | no |
| <a name="input_ccvm_image_version"></a> [ccvm\_image\_version](#input\_ccvm\_image\_version) | Azure Marketplace Cloud Connector Image Version | `string` | `"latest"` | no |
| <a name="input_ccvm_instance_type"></a> [ccvm\_instance\_type](#input\_ccvm\_instance\_type) | Cloud Connector Image size | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_ccvm_source_image_id"></a> [ccvm\_source\_image\_id](#input\_ccvm\_source\_image\_id) | Custom Cloud Connector Source Image ID. Set this value to the path of a local subscription Microsoft.Compute image to override the Cloud Connector deployment instead of using the marketplace publisher | `string` | `null` | no |
| <a name="input_domain_names"></a> [domain\_names](#input\_domain\_names) | Domain names fqdn/wildcard to have Azure Private DNS redirect DNS requests to Cloud Connector | `map(any)` | n/a | yes |
| <a name="input_encryption_at_host_enabled"></a> [encryption\_at\_host\_enabled](#input\_encryption\_at\_host\_enabled) | User input for enabling or disabling host encryption | `bool` | `true` | no |
| <a name="input_env_subscription_id"></a> [env\_subscription\_id](#input\_env\_subscription\_id) | Azure Subscription ID where resources are to be deployed in | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Customer defined environment tag. ie: Dev, QA, Prod, etc. | `string` | `"Development"` | no |
| <a name="input_existing_log_analytics_workspace"></a> [existing\_log\_analytics\_workspace](#input\_existing\_log\_analytics\_workspace) | Set to True if you wish to use an existing Log Analytics Workspace to associate with the AppInsights Instance. Default is false meaning Terraform module will create a new one | `bool` | `false` | no |
| <a name="input_existing_log_analytics_workspace_id"></a> [existing\_log\_analytics\_workspace\_id](#input\_existing\_log\_analytics\_workspace\_id) | ID of existing Log Analytics Workspace to associate with the AppInsights Instance. | `string` | `""` | no |
| <a name="input_existing_storage_account"></a> [existing\_storage\_account](#input\_existing\_storage\_account) | Set to True if you wish to use an existing Storage Account to associate with the Function App. Default is false meaning Terraform module will create a new one | `bool` | `false` | no |
| <a name="input_existing_storage_account_name"></a> [existing\_storage\_account\_name](#input\_existing\_storage\_account\_name) | Name of existing Storage Account to associate with the Function App. | `string` | `""` | no |
| <a name="input_existing_storage_account_rg"></a> [existing\_storage\_account\_rg](#input\_existing\_storage\_account\_rg) | Resource Group of existing Storage Account to associate with the Function App. | `string` | `""` | no |
| <a name="input_function_app_managed_identity_name"></a> [function\_app\_managed\_identity\_name](#input\_function\_app\_managed\_identity\_name) | Azure Managed Identity name to attach to the Function App. E.g zspreview-66117-mi | `string` | `""` | no |
| <a name="input_function_app_managed_identity_rg"></a> [function\_app\_managed\_identity\_rg](#input\_function\_app\_managed\_identity\_rg) | Resource Group of the Azure Managed Identity name to attach to the Function App. E.g. edgeconnector\_rg\_1 | `string` | `""` | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | The interval, in seconds, for how frequently to probe the endpoint for health status. Typically, the interval is slightly less than half the allocated timeout period (in seconds) which allows two full probes before taking the instance out of rotation. The default value is 15, the minimum value is 5 | `number` | `15` | no |
| <a name="input_http_probe_port"></a> [http\_probe\_port](#input\_http\_probe\_port) | Port number for Cloud Connector cloud init to enable listener port for HTTP probe from Azure LB | `number` | `50000` | no |
| <a name="input_load_distribution"></a> [load\_distribution](#input\_load\_distribution) | Azure LB load distribution method | `string` | `"Default"` | no |
| <a name="input_managed_identity_subscription_id"></a> [managed\_identity\_subscription\_id](#input\_managed\_identity\_subscription\_id) | Azure Subscription ID where the User Managed Identity resource exists. Only required if this Subscription ID is different than env\_subscription\_id | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The name prefix for all your resources | `string` | `"zscc"` | no |
| <a name="input_network_address_space"></a> [network\_address\_space](#input\_network\_address\_space) | VNet IP CIDR Range. All subnet resources that might get created (public, workload, cloud connector) are derived from this /16 CIDR. If you require creating a VNet smaller than /16, you may need to explicitly define all other subnets via public\_subnets, workload\_subnets, cc\_subnets, and route53\_subnets variables | `string` | `"10.1.0.0/16"` | no |
| <a name="input_number_of_probes"></a> [number\_of\_probes](#input\_number\_of\_probes) | The number of probes where if no response, will result in stopping further traffic from being delivered to the endpoint. This values allows endpoints to be taken out of rotation faster or slower than the typical times used in Azure | `number` | `1` | no |
| <a name="input_owner_tag"></a> [owner\_tag](#input\_owner\_tag) | Customer defined owner tag value. ie: Org, Dept, username, etc. | `string` | `"zscc-admin"` | no |
| <a name="input_path_to_scripts"></a> [path\_to\_scripts](#input\_path\_to\_scripts) | Path to script\_directory | `string` | `""` | no |
| <a name="input_private_dns_subnet"></a> [private\_dns\_subnet](#input\_private\_dns\_subnet) | Private DNS Resolver Outbound Endpoint Subnet to create in VNet. This is only required if you want to override the default subnet that this code creates via network\_address\_space variable. | `string` | `null` | no |
| <a name="input_probe_threshold"></a> [probe\_threshold](#input\_probe\_threshold) | The number of consecutive successful or failed probes in order to allow or deny traffic from being delivered to this endpoint. After failing the number of consecutive probes equal to this value, the endpoint will be taken out of rotation and require the same number of successful consecutive probes to be placed back in rotation. | `number` | `2` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Public/Bastion Subnets to create in VNet. This is only required if you want to override the default subnets that this code creates via network\_address\_space variable. | `list(string)` | `null` | no |
| <a name="input_run_manual_sync"></a> [run\_manual\_sync](#input\_run\_manual\_sync) | Set to True if you would like terraform to run the manual sync operation to start the Function App after creation. The alternative is to navigate to the Function App on the Azure Portal UI or to manually invoke the script yourself. | `bool` | `true` | no |
| <a name="input_scale_in_threshold"></a> [scale\_in\_threshold](#input\_scale\_in\_threshold) | Metric threshold for determining scale in. | `number` | `50` | no |
| <a name="input_scale_out_threshold"></a> [scale\_out\_threshold](#input\_scale\_out\_threshold) | Metric threshold for determining scale out. | `number` | `70` | no |
| <a name="input_scheduled_scaling_days_of_week"></a> [scheduled\_scaling\_days\_of\_week](#input\_scheduled\_scaling\_days\_of\_week) | Days of the week to apply scheduled scaling profile. | `list(string)` | <pre>[<br/>  "Monday",<br/>  "Tuesday",<br/>  "Wednesday",<br/>  "Thursday",<br/>  "Friday"<br/>]</pre> | no |
| <a name="input_scheduled_scaling_enabled"></a> [scheduled\_scaling\_enabled](#input\_scheduled\_scaling\_enabled) | Enable scheduled scaling on top of metric scaling. | `bool` | `false` | no |
| <a name="input_scheduled_scaling_end_time_hour"></a> [scheduled\_scaling\_end\_time\_hour](#input\_scheduled\_scaling\_end\_time\_hour) | Hour to end scheduled scaling profile. | `number` | `17` | no |
| <a name="input_scheduled_scaling_end_time_min"></a> [scheduled\_scaling\_end\_time\_min](#input\_scheduled\_scaling\_end\_time\_min) | Minute to end scheduled scaling profile. | `number` | `0` | no |
| <a name="input_scheduled_scaling_start_time_hour"></a> [scheduled\_scaling\_start\_time\_hour](#input\_scheduled\_scaling\_start\_time\_hour) | Hour to start scheduled scaling profile. | `number` | `9` | no |
| <a name="input_scheduled_scaling_start_time_min"></a> [scheduled\_scaling\_start\_time\_min](#input\_scheduled\_scaling\_start\_time\_min) | Minute to start scheduled scaling profile. | `number` | `0` | no |
| <a name="input_scheduled_scaling_timezone"></a> [scheduled\_scaling\_timezone](#input\_scheduled\_scaling\_timezone) | Timezone the times for the scheduled scaling profile are specified in. | `string` | `"Pacific Standard Time"` | no |
| <a name="input_scheduled_scaling_vmss_min_ccs"></a> [scheduled\_scaling\_vmss\_min\_ccs](#input\_scheduled\_scaling\_vmss\_min\_ccs) | Minimum number of CCs in vmss for scheduled scaling profile. | `number` | `2` | no |
| <a name="input_support_access_enabled"></a> [support\_access\_enabled](#input\_support\_access\_enabled) | If Network Security Group is being configured, enable a specific outbound rule for Cloud Connector to be able to establish connectivity for Zscaler support access. Default is true | `bool` | `true` | no |
| <a name="input_target_address"></a> [target\_address](#input\_target\_address) | Azure DNS queries will be conditionally forwarded to these target IP addresses. Default are a pair of Zscaler Global VIP addresses | `list(string)` | <pre>[<br/>  "185.46.212.88",<br/>  "185.46.212.89"<br/>]</pre> | no |
| <a name="input_terminate_unhealthy_instances"></a> [terminate\_unhealthy\_instances](#input\_terminate\_unhealthy\_instances) | Indicate whether detected unhealthy instances are terminated or not. | `bool` | `true` | no |
| <a name="input_tls_key_algorithm"></a> [tls\_key\_algorithm](#input\_tls\_key\_algorithm) | algorithm for tls\_private\_key resource | `string` | `"RSA"` | no |
| <a name="input_upload_function_app_zip"></a> [upload\_function\_app\_zip](#input\_upload\_function\_app\_zip) | By default, this Terraform will create a new Storage Account/Container/Blob to upload the zip file. The function app will pull from the blobl url to run. Setting this value to false will prevent creation/upload of the blob file | `bool` | `true` | no |
| <a name="input_vmss_default_ccs"></a> [vmss\_default\_ccs](#input\_vmss\_default\_ccs) | Default number of CCs in vmss. | `number` | `2` | no |
| <a name="input_vmss_max_ccs"></a> [vmss\_max\_ccs](#input\_vmss\_max\_ccs) | Maximum number of CCs in vmss. | `number` | `16` | no |
| <a name="input_vmss_min_ccs"></a> [vmss\_min\_ccs](#input\_vmss\_min\_ccs) | Minimum number of CCs in vmss. | `number` | `2` | no |
| <a name="input_workload_count"></a> [workload\_count](#input\_workload\_count) | The number of Workload VMs to deploy | `number` | `1` | no |
| <a name="input_workloads_subnets"></a> [workloads\_subnets](#input\_workloads\_subnets) | Workload Subnets to create in VNet. This is only required if you want to override the default subnets that this code creates via network\_address\_space variable. | `list(string)` | `null` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Specify which availability zone(s) to deploy VM resources in if zones\_enabled variable is set to true | `list(string)` | <pre>[<br/>  "1"<br/>]</pre> | no |
| <a name="input_zones_enabled"></a> [zones\_enabled](#input\_zones\_enabled) | Determine whether to provision Cloud Connector VMs explicitly in defined zones (if supported by the Azure region provided in the location variable). If left false, Azure will automatically choose a zone and module will create an availability set resource instead for VM fault tolerance | `bool` | `false` | no |
| <a name="input_zpa_enabled"></a> [zpa\_enabled](#input\_zpa\_enabled) | Configure Azure Private DNS Outbound subnet, Resolvers, Rulesets/Rules, and Outbound Endpoint ZPA DNS redirection | `bool` | `true` | no |
| <a name="input_zscaler_cc_function_public_url"></a> [zscaler\_cc\_function\_public\_url](#input\_zscaler\_cc\_function\_public\_url) | Publicly accessible URL path where Function App can pull its zip file build from. This is only required when var.upload\_function\_app\_zip is set to false | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_testbedconfig"></a> [testbedconfig](#output\_testbedconfig) | Azure Testbed results |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
