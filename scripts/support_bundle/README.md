# Support Bundle Generation Script

This script is to be used to collect information on your Cloud Connector Scale Set Deployment Zscaler Customer Support. The script will collect the health and scale metrics published by the Cloud Connectors, the configuration of the Scale Set deployment, and the logs from the Function App. This bundle will be used for debugging purposes to help support customer.

## Running Script
```
cd scripts/support_bundle
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python generate_support_bundle.py --resource_group <resource-group> --time_duration <time-in-min> --subscription_id <subscription-id> --tenant_id <(optional)tenant-id> --client_id <(optional)client-id> --client_secret <(optional)client-secret>
```

1. Navigate to the support_bundle directory
2. Setup virtual environment to run the script in
3. activate the virutal environment
4. install required libraries
5. Execute support bundle generate script

### Mandatory Script Arguments
- resource_group: Resource Group the Cloud Connector Scale Sets are deployed into
- time_duration: Time in minutes minutes to go back and collect logs from. For instance, time_duration=60 would mean metrics and logs would be collected for the past 60 min.
- subscription_id: Subscription ID the Cloud Connector deployment is deployed into

### Optional Script Arguments
The following arguments only need to be passed if the az CLI is not installed and configured with credentials. The following options provide the ability to pass in Service Principal credentials to run the script. The script does a number of read operations so it is advised to give admin permissions when running this script.

- tenant_id: Azure Tenant ID
- client_id: Service Principal Client ID
- client_secret: Service Principal Client Secret

## Script Outputs
The script will output a zip file in the same support_bundle directory. This zip file will contain 3 directories: config, logs, metrics.

- config: This directory will hold configuration information for each of the scale sets that are deployed in the Resource Group.
- logs: This directory will hold logs for the Function Apps that are managed the Scale Sets.
- metrics: This directory will hold metrics being published by the Cloud Connectors. Metric types include scaling (cpu, mem, bytes in/out) and health metrics.
