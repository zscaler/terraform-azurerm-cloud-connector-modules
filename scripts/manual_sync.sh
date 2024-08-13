#!/bin/bash


# read in subcription ID, resource group, and function app as arguments
subscription_id=$1
resource_group=$2
function_app=$3
if [[ $subscription_id == "" || $resource_group == "" || $function_app == "" ]]; then
    echo "Arguments are missing. Expected arguments are Subscription ID, Resource Group, Function App"
    exit 1
fi

if [[ "$ARM_TENANT_ID" != "" ]]; then
    echo "ARM_TENANT_ID ENV variable is set, using ENV variables to get access token."
    # if env variable is set, take credential values from env variables
    tenant_id="$ARM_TENANT_ID"
    client_id="$ARM_CLIENT_ID"
    client_secret="$ARM_CLIENT_SECRET"
    # make call to get access token
    auth_response=$(curl --location "https://login.microsoftonline.com/${tenant_id}/oauth2/token" \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --data-urlencode "grant_type=client_credentials" \
        --data-urlencode "client_id=${client_id}" \
        --data-urlencode "client_secret=${client_secret}" \
        --data-urlencode "resource=https://management.azure.com/")
    # extract access token
    access_token=$(jq --argjson j "$auth_response" -n '$j.access_token' | cut -d "\"" -f 2)
else
    echo "ARM_TENANT_ID ENV variable is not set, attempting to use AZ CLI to get access token."
    az account set --subscription ${subscription_id}
    auth_response=$(az account get-access-token)
    if [[ $auth_response == "" ]]; then
        echo "AZ CLI not installed on system, please install AZ CLI or set ENV variables ARM_TENANT_ID, ARM_CLIENT_ID, " \
             "ARM_CLIENT_SECRET to their respective values. Error: ${account_response}"
        exit 1
    fi
    access_token=$(jq --argjson j "$auth_response" -n '$j.accessToken' | cut -d "\"" -f 2)
fi

if [[ $access_token == "" ]]; then
    echo "Failed to obtain access token. Error: ${auth_response}"
    exit 1
fi

# make POST call to manually sync function
output=$(curl --request POST "https://management.azure.com/subscriptions/${subscription_id}/resourceGroups/${resource_group}/providers/Microsoft.Web/sites/${function_app}/syncfunctiontriggers?api-version=2016-08-01" \
    --header "Authorization: Bearer ${access_token}" \
    --header "Content-Length: 0")
if [[ $output == "{\"status\":\"success\"}" ]]; then
    echo "success"
else
    echo "Failed. Output: ${output}"
    exit 1
fi

exit 0
