#!/usr/bin/env python3
import os
import shutil
import argparse
from datetime import timedelta, datetime
import json
import time

from azure.identity import DefaultAzureCredential, ClientSecretCredential
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.monitor import MonitorManagementClient
from azure.monitor.query import LogsQueryClient, LogsQueryStatus, MetricsQueryClient, MetricAggregationType
from azure.core.pipeline.transport import RequestsTransport


ROOT_BUNDLE_PATH = "support_bundle"
LOGS_PATH = f"{ROOT_BUNDLE_PATH}/logs"
METRICS_PATH = f"{ROOT_BUNDLE_PATH}/metrics"
CONFIG_PATH = f"{ROOT_BUNDLE_PATH}/config"

def parse_vmss_name(vmss_id):
    return vmss_id.split("/")[-1]

def parse_vm_name(vm_id):
    return vm_id.split("/")[-1]

def extract_vm_id_from_vmss_vm_id(vmss_vm_id):
    temp = vmss_vm_id.split("/")
    return f"/{temp[1]}/{temp[2]}/{temp[3]}/{temp[4]}/{temp[5]}/{temp[6]}/{temp[9]}/{temp[10]}"


class SupportBundle:

    def __init__(self, credential, subscription_id, resource_group, time_duration, app_insights_id=None, vmss_ids={}):
        self.credential = credential
        self.subscription_id = subscription_id
        self.resource_group = resource_group
        self.time_duration = time_duration

        self.app_insights_id = app_insights_id
        self.vmss_ids = vmss_ids


    def init_support_bundle_directory(self):
        # check if directory exists
        if os.path.exists(ROOT_BUNDLE_PATH):
            # if so delete it
            shutil.rmtree(ROOT_BUNDLE_PATH, ignore_errors=False)

        # create new directory for each path
        os.mkdir(ROOT_BUNDLE_PATH)
        os.mkdir(LOGS_PATH)
        os.mkdir(METRICS_PATH)
        os.mkdir(CONFIG_PATH)


    def init_resource_group_resources(self):
        # list resources in resource group
        resource_client = ResourceManagementClient(
            credential=self.credential,
            subscription_id=self.subscription_id
        )
        resp = resource_client.resources.list_by_resource_group(resource_group_name=self.resource_group)

        # parse resources to find app insights + vmss resources
        for resource in resp:
            if "Microsoft.Insights/components" in resource.type:
                self.app_insights_id = resource.id
            elif "Microsoft.Compute/virtualMachineScaleSets" in resource.type:
                self.vmss_ids[resource.id] = {
                    'ExistingInstances': set(),
                    'TerminatedInstances': set()
                }
        if self.app_insights_id is None:
            raise Exception("Failed to find app insights instance.")
        if len(self.vmss_ids) == 0:
            raise Exception("Failed to find scale sets.")


    def get_function_logs(self, function_name):
        transport = RequestsTransport(connection_verify=False)
        logs_query_client = LogsQueryClient(self.credential, transport=transport)
        query = (
            "union traces"
            "| union exceptions"
            f"| where customDimensions['Category'] == 'Function.{function_name}.User' or customDimensions['Category'] == 'Function.{function_name}'"
            "| order by timestamp asc"
            "| project timestamp, message = iff(message != '', message, iff(innermostMessage != '', innermostMessage, customDimensions.['prop__{OriginalFormat}'])), logLevel = customDimensions.['LogLevel']"
        )

        response = logs_query_client.query_resource(self.app_insights_id, query, timespan=timedelta(minutes=self.time_duration))
        if response.status == LogsQueryStatus.PARTIAL:
            raise Exception(f"Error: Failed to get logs: {response.partial_error}")
        elif response.status == LogsQueryStatus.SUCCESS:
            data = response.tables
        return data


    def write_logs_to_file(self, data, log_file):
        with open(log_file, "w") as file_obj:
            for table in data:
                for row in table.rows:
                    timestamp = row[0]
                    log_level = row[2]
                    message = row[1]
                    file_obj.write(f"{timestamp} - {log_level}: {message}\n")


    def handle_function_app_logs(self):
        for function in ["healthMonitor", "synchronizeCloudResources"]:
            # get function logs
            data = self.get_function_logs(function_name=function)
            # write logs to file
            self.write_logs_to_file(data=data, log_file=f"{LOGS_PATH}/{function}.txt")


    def handle_scale_set_config_directory(self, vmss_name):
        path = f"{CONFIG_PATH}/{vmss_name}"
        if not os.path.exists(path):
            # create new directory vmss
            os.mkdir(path)
        return path


    def log_scale_set_config(self, vmss_name, log_directory):
        # get scale set config
        client = ComputeManagementClient(
            credential=self.credential,
            subscription_id=self.subscription_id,
        )
        response = client.virtual_machine_scale_sets.get(
            resource_group_name=self.resource_group,
            vm_scale_set_name=vmss_name
        )

        # write config to log file
        log_file = f"{log_directory}/scale_set_config.txt"
        with open(log_file, "w") as file_obj:
            file_obj.write(json.dumps(response.as_dict()))


    def log_scale_set_scaling_config(self, vmss_id, log_directory):
        # get scale set scaling config
        monitor_client = MonitorManagementClient(
            credential=self.credential,
            subscription_id=self.subscription_id,
        )
        resp = monitor_client.autoscale_settings.list_by_resource_group(
            resource_group_name=self.resource_group,
        )
        scale_config = []
        for item in resp:
            if item.target_resource_uri == vmss_id:
                scale_config.append(item.as_dict())

        # write config to log file
        log_file = f"{log_directory}/scaling_rules_config.txt"
        with open(log_file, "w") as file_obj:
            for config in scale_config:
                file_obj.write(json.dumps(config))
                file_obj.write("\n")


    def log_scale_set_current_instances(self, vmss_id, log_directory):
        # get instances in vmss
        client = ComputeManagementClient(
            credential=self.credential,
            subscription_id=self.subscription_id,
        )
        response = client.virtual_machine_scale_set_vms.list(
            resource_group_name=self.resource_group,
            virtual_machine_scale_set_name=parse_vmss_name(vmss_id),
        )
        instances = []
        for item in response:
            instances.append(item.as_dict())
            self.vmss_ids[vmss_id]['ExistingInstances'].add(item.id)

        # write config to log file
        log_file = f"{log_directory}/scale_set_instances.txt"
        with open(log_file, "w") as file_obj:
            for vm in instances:
                file_obj.write(json.dumps(vm))
                file_obj.write("\n")


    def log_scale_set_history(self, vmss_id, log_directory):
        # get scaling history
        client = MonitorManagementClient(
            credential=self.credential,
            subscription_id=self.subscription_id
        )
        _time = datetime.now()-timedelta(minutes=self.time_duration)
        resp = client.activity_logs.list(
            filter="eventTimestamp ge {} and resourceUri eq {}".format(_time, vmss_id),
            select="authorization, correlationId, description, eventDataId, eventName, eventTimestamp, level, "\
                    "operationId, operationName, properties, resourceGroupName, resourceProviderName, resourceId, "\
                    "status, submissionTimestamp, subStatus, subscriptionId"
        )
        activities = []
        for item in resp:
            if item.operation_name.value == "Microsoft.Insights/AutoscaleSettings/Scaleup/Action":
                activities.append(item.as_dict())
            elif item.operation_name.value == "Microsoft.Insights/AutoscaleSettings/ScaleupResult/Action":
                activities.append(item.as_dict())
            elif item.operation_name.value == "Microsoft.Insights/AutoscaleSettings/Scaledown/Action":
                activities.append(item.as_dict())
            elif item.operation_name.value == "Microsoft.Insights/AutoscaleSettings/ScaledownResult/Action":
                activities.append(item.as_dict())

        # write activities to log file
        log_file = f"{log_directory}/scale_set_activity_log.txt"
        with open(log_file, "w") as file_obj:
            for item in activities:
                file_obj.write(json.dumps(item))
                file_obj.write("\n")


    def log_virtual_machine_history(self, vmss_id, log_directory):
        client = MonitorManagementClient(
            credential=self.credential,
            subscription_id=self.subscription_id
        )
        _time = datetime.now()-timedelta(minutes=self.time_duration)
        resp = client.activity_logs.list(
            filter="eventTimestamp ge {} and resourceGroupName eq {} and resourceType eq Microsoft.Compute/virtualMachines".format(_time, self.resource_group),
            select="authorization, correlationId, description, eventDataId, eventName, eventTimestamp, level, "\
                   "operationId, operationName, properties, resourceGroupName, resourceProviderName, resourceId, "\
                   "status, submissionTimestamp, subStatus, subscriptionId"
        )
        activities = []
        vmss_name = parse_vmss_name(vmss_id)
        for item in resp:
            if vmss_name not in item.resource_id:
                continue
            if item.operation_name.value == "Microsoft.Compute/virtualMachines/delete":
                activities.append(item.as_dict())
                if item.resource_id not in self.vmss_ids[vmss_id]['ExistingInstances']:
                    self.vmss_ids[vmss_id]['TerminatedInstances'].add(item.resource_id)
            if item.operation_name.value == "Microsoft.Compute/virtualMachines/write":
                activities.append(item.as_dict())
                if item.resource_id not in self.vmss_ids[vmss_id]['ExistingInstances']:
                    self.vmss_ids[vmss_id]['TerminatedInstances'].add(item.resource_id)

        # write activities to log file
        log_file = f"{log_directory}/vm_activity_log.txt"
        with open(log_file, "w") as file_obj:
            for item in activities:
                file_obj.write(json.dumps(item))
                file_obj.write("\n")


    def handle_scale_set_config(self):
        for vmss_id, _ in self.vmss_ids.items():
            # create scale set directory
            vmss_directory = self.handle_scale_set_config_directory(vmss_name=parse_vmss_name(vmss_id))

            # get and write config to log
            self.log_scale_set_config(vmss_name=parse_vmss_name(vmss_id), log_directory=vmss_directory)
            self.log_scale_set_scaling_config(vmss_id=vmss_id, log_directory=vmss_directory)
            self.log_scale_set_current_instances(vmss_id=vmss_id, log_directory=vmss_directory)

            # get and write scaling history to log
            self.log_scale_set_history(vmss_id=vmss_id, log_directory=vmss_directory)
            self.log_virtual_machine_history(vmss_id=vmss_id, log_directory=vmss_directory)


    def handle_scale_set_metric_directory(self, vmss_name):
        path = f"{METRICS_PATH}/{vmss_name}"
        if not os.path.exists(path):
            # create new directory vmss
            os.mkdir(path)
        return path


    def log_scaling_metrics(self, vmss_id, log_directory, vm_name=None):
        # collect metrics for each dimension
        client = MetricsQueryClient(self.credential)
        metric_dimensions = ['smedge_cpu_utilization', 'smedge_mem_utilization', 'smedge_bytes_in', 'smedge_bytes_out']
        results = {}
        for dimension in metric_dimensions:
            results[dimension] = []
            if vm_name is None:
                _filter = "metric_name eq '{}'".format(dimension)
            else:
                _filter = "metric_name eq '{}' and InstanceId eq '{}'".format(dimension, vm_name)
            response = client.query_resource(
                vmss_id,
                metric_names=["smedge_metrics"],
                metric_namespace="Zscaler/CloudConnectors",
                timespan=timedelta(minutes=self.time_duration),
                granularity=timedelta(minutes=1),
                aggregations=[MetricAggregationType.AVERAGE],
                filter=_filter
            )

            for metric in response.metrics:
                for time_series_element in metric.timeseries:
                    for metric_value in time_series_element.data:
                        results[dimension].append(f"Name: {metric.name}, Value: {metric_value.average}, Timestamp: {metric_value.timestamp}")

        # write metric to log file
        log_file = f"{log_directory}/scaling_metrics.txt"
        with open(log_file, "w") as file_obj:
            for dimension, values in results.items():
                file_obj.write(f"--------------------------------{dimension}--------------------------------\n")
                for val in values:
                    file_obj.write(val)
                    file_obj.write("\n")
                file_obj.write("\n\n")


    def handle_virtual_machine_metric_directory(self, vmss_name, vm_name):
        path = f"{METRICS_PATH}/{vmss_name}/{vm_name}"
        if not os.path.exists(path):
            # create new directory vmss
            os.mkdir(path)
        return path


    def log_health_metrics(self, vmss_vm_id, log_directory):
        # collect metrics for each dimension
        client = MetricsQueryClient(self.credential)
        vm_id = extract_vm_id_from_vmss_vm_id(vmss_vm_id)
        response = client.query_resource(
            vm_id,
            metric_names=["cloud_connector_aggr_health"],
            metric_namespace="Zscaler/CloudConnectors",
            timespan=timedelta(minutes=self.time_duration),
            granularity=timedelta(minutes=1),
            aggregations=[MetricAggregationType.AVERAGE]
        )

        values = []
        for metric in response.metrics:
            for time_series_element in metric.timeseries:
                for metric_value in time_series_element.data:
                    values.append(f"Name: {metric.name}, Value: {metric_value.average}, Timestamp: {metric_value.timestamp}")

        # write metric to log file
        log_file = f"{log_directory}/health_metrics.txt"
        with open(log_file, "w") as file_obj:
            for val in values:
                file_obj.write(val)
                file_obj.write("\n")


    def handle_scale_set_metrics(self):
        # can i get scale metrics for individual instances that published them?
        # can i get health metrics for instances that have been terminated
        for vmss_id, _ in self.vmss_ids.items():
            # create scale set directory
            vmss_directory = self.handle_scale_set_metric_directory(vmss_name=parse_vmss_name(vmss_id))

            # handle scale set scaling metrics
            self.log_scaling_metrics(
                vmss_id=vmss_id, 
                log_directory=vmss_directory
            )

            # handle instance scaling metrics
            for vm_id in self.vmss_ids[vmss_id]['ExistingInstances'].union(self.vmss_ids[vmss_id]['TerminatedInstances']):
                # create VM metric directory
                vm_directory = self.handle_virtual_machine_metric_directory(
                    vmss_name=parse_vmss_name(vmss_id),
                    vm_name=parse_vm_name(vm_id)
                )

                # handle instance scaling metrics
                self.log_scaling_metrics(
                    vmss_id=vmss_id, 
                    log_directory=vm_directory,
                    vm_name=parse_vm_name(vm_id)
                )

                if vm_id not in self.vmss_ids[vmss_id]['ExistingInstances']:
                    continue

                self.log_health_metrics(
                    vmss_vm_id=vm_id,
                    log_directory=vm_directory 
                )


    def compress_support_bundle(self):
        # compress directory
        zip_file_name = f"support_bundle_{int(time.time())}"
        shutil.make_archive(zip_file_name, 'zip', ROOT_BUNDLE_PATH)

        # remove directory
        shutil.rmtree(ROOT_BUNDLE_PATH, ignore_errors=False)

        # return zip file name
        return zip_file_name


    def generate_support_bundle(self):
        # set up support bundle directory
        self.init_support_bundle_directory()

        # get app insights + vmss resources
        self.init_resource_group_resources()

        # handle logs for azure function app
        self.handle_function_app_logs()

        # handle config for scale sets
        self.handle_scale_set_config()
        
        # handle metrics for scale sets
        self.handle_scale_set_metrics()

        # generate compressed support bundle
        file_name = self.compress_support_bundle()
        print(f"\n\nSupport Bundle File: {file_name}\n\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-rg','--resource_group', help='Resource Group Name', required=True)
    parser.add_argument(
        '-td','--time_duration', help='Duration of time to look back for logs/metrics (minutes).', required=False, 
        default=3600, type=int
    )
    parser.add_argument(
       '-s','--subscription_id', help='Subscription ID, required only if using Service Principal for credentials.', 
        required=True
    )
    parser.add_argument(
        '-t','--tenant_id', help='(Optional) Tenant ID, required only if using Service Principal for credentials.', 
        required=False
    )
    parser.add_argument(
        '-c','--client_id', help='(Optional) Client ID, required only if using Service Principal for credentials.', 
        required=False
    )
    parser.add_argument(
        '-cs','--client_secret', help='(Optional) Client Secret, required only if using Service Principal for credentials.', 
        required=False
    )
    args = parser.parse_args()

    if args.tenant_id and args.client_id and args.client_secret:
        credential = ClientSecretCredential(tenant_id=args.tenant_id, client_id=args.client_id, client_secret=args.client_secret)
    else:
        credential = DefaultAzureCredential()

    support_bundle_obj = SupportBundle(
        credential=credential, 
        subscription_id=args.subscription_id,
        resource_group=args.resource_group, 
        time_duration=args.time_duration
    )
    support_bundle_obj.generate_support_bundle()
