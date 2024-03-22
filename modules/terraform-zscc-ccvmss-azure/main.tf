################################################################################
# Create Cloud Connector VMSS
################################################################################
resource "azurerm_orchestrated_virtual_machine_scale_set" "cc_vmss" {
  name                        = "${var.name_prefix}-ccvmss-${var.resource_tag}"
  location                    = var.location
  resource_group_name         = var.resource_group
  platform_fault_domain_count = var.fault_domain_count
  sku_name                    = var.ccvm_instance_type
  encryption_at_host_enabled  = var.encryption_at_host_enabled
  zones                       = var.zones
  zone_balance                = false
  instances                   = var.vmss_desired_ccs
  termination_notification {
    enabled = true
    timeout = "PT5M"
  }

  network_interface {
    name                      = "${var.name_prefix}-ccvmss-mgmt-nic-${var.resource_tag}"
    primary                   = true
    network_security_group_id = var.mgmt_nsg_id

    ip_configuration {
      name      = "${var.name_prefix}-ccvmss-mgmt-nic-conf-${var.resource_tag}"
      primary   = true
      subnet_id = var.mgmt_subnet_id
    }
  }

  network_interface {
    name                          = "${var.name_prefix}-ccvmss-fwd-nic-${var.resource_tag}"
    enable_accelerated_networking = var.accelerated_networking_enabled
    enable_ip_forwarding          = true
    network_security_group_id     = var.service_nsg_id

    ip_configuration {
      name                                   = "${var.name_prefix}-ccvmss-fwd-nic-conf-${var.resource_tag}"
      primary                                = true
      subnet_id                              = var.service_subnet_id
      load_balancer_backend_address_pool_ids = [var.backend_address_pool]
    }
  }

  os_profile {
    custom_data = base64encode(var.user_data)
    linux_configuration {
      admin_username = var.cc_username
      admin_ssh_key {
        username   = var.cc_username
        public_key = "${trimspace(var.ssh_key)} ${var.cc_username}@me.io"
      }
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  plan {
    publisher = var.ccvm_image_publisher
    name      = var.ccvm_image_sku
    product   = var.ccvm_image_offer
  }

  source_image_reference {
    publisher = var.ccvm_image_publisher
    offer     = var.ccvm_image_offer
    sku       = var.ccvm_image_sku
    version   = var.ccvm_image_version
  }

  tags = var.global_tags

  depends_on = [
    var.backend_address_pool
  ]
}


resource "azurerm_monitor_autoscale_setting" "vmss_autoscale_setting" {
  name                = "custom-scale-rule"
  resource_group_name = var.resource_group
  location            = var.location
  target_resource_id  = azurerm_orchestrated_virtual_machine_scale_set.cc_vmss.id

  profile {
    name = "defaultProfile"

    capacity {
      default = var.vmss_desired_ccs
      minimum = var.vmss_min_ccs
      maximum = var.vmss_max_ccs
    }

    rule {
      metric_trigger {
        metric_name        = "smedge_cpu_util"
        metric_resource_id = azurerm_orchestrated_virtual_machine_scale_set.cc_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = var.scale_out_evaluation_period
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.scale_out_threshold
        metric_namespace   = "Zscaler/CloudConnectors"
        #dimensions {
        #  name     = "AppName"
        #  operator = "Equals"
        #  values   = ["App1"]
        #}
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = var.scale_out_count
        cooldown  = var.scale_out_cooldown
      }
    }

    rule {
      metric_trigger {
        metric_name        = "smedge_cpu_util"
        metric_resource_id = azurerm_orchestrated_virtual_machine_scale_set.cc_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = var.scale_in_evaluation_period
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.scale_in_threshold
        metric_namespace   = "Zscaler/CloudConnectors"
        #dimensions {
        #  name     = "AppName"
        #  operator = "Equals"
        #  values   = ["App1"]
        #}
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = var.scale_in_count
        cooldown  = var.scale_in_cooldown
      }
    }

    dynamic "recurrence" {
      for_each = var.scheduled_scaling_enabled != false ? ["apply"] : []
      content {
        timezone = var.scheduled_scaling_timezone
        days     = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        hours    = [var.scheduled_scaling_end_time_hour]
        minutes  = [var.scheduled_scaling_end_time_min]
      }
    }

  }

  dynamic "profile" {
    for_each = var.scheduled_scaling_enabled != false ? ["apply"] : []
    content {
      name = "ScheduledProfile"

      capacity {
        default = var.scheduled_scaling_vmss_min_ccs
        minimum = var.scheduled_scaling_vmss_min_ccs
        maximum = var.vmss_max_ccs
      }

      rule {
        metric_trigger {
          metric_name        = "smedge_cpu_util"
          metric_resource_id = azurerm_orchestrated_virtual_machine_scale_set.cc_vmss.id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = var.scale_out_evaluation_period
          time_aggregation   = "Average"
          operator           = "GreaterThan"
          threshold          = var.scale_out_threshold
          metric_namespace   = "Zscaler/CloudConnectors"
          #dimensions {
          #  name     = "AppName"
          #  operator = "Equals"
          #  values   = ["App1"]
          #}
        }

        scale_action {
          direction = "Increase"
          type      = "ChangeCount"
          value     = var.scale_out_count
          cooldown  = var.scale_out_cooldown
        }
      }

      rule {
        metric_trigger {
          metric_name        = "smedge_cpu_util"
          metric_resource_id = azurerm_orchestrated_virtual_machine_scale_set.cc_vmss.id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = var.scale_in_evaluation_period
          time_aggregation   = "Average"
          operator           = "LessThan"
          threshold          = var.scale_in_threshold
          metric_namespace   = "Zscaler/CloudConnectors"
          #dimensions {
          #  name     = "AppName"
          #  operator = "Equals"
          #  values   = ["App1"]
          #}
        }

        scale_action {
          direction = "Decrease"
          type      = "ChangeCount"
          value     = var.scale_in_count
          cooldown  = var.scale_in_cooldown
        }
      }

      recurrence {
        timezone = var.scheduled_scaling_timezone
        days     = var.scheduled_scaling_days_of_week
        hours    = [var.scheduled_scaling_start_time_hour]
        minutes  = [var.scheduled_scaling_start_time_min]
      }
    }
  }
}


resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.resource_tag}storage"
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.name_prefix}-ccvmss-${var.resource_tag}-app-service-plan"
  resource_group_name = var.resource_group
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_application_insights" "orchestration_app_insights" {
  name                = "${var.name_prefix}-ccvmss-${var.resource_tag}-app-insights"
  location            = var.location
  resource_group_name = var.resource_group
  application_type    = "web"
}

data "local_file" "zscaler_function_app_file" {
  count    = var.zscaler_cc_function_deploy_local_file ? 1 : 0
  filename = var.zscaler_cc_function_file_path
}

resource "random_string" "function_app_hash" {
  count   = var.zscaler_cc_function_deploy_local_file ? 1 : 0
  length  = 32
  special = false
  upper   = false
  keepers = {
    zipped_code = data.local_file.zscaler_function_app_file[0].content_md5
  }
}

resource "local_file" "function_app_src_code" {
  count          = var.zscaler_cc_function_deploy_local_file ? 1 : 0
  content_base64 = filebase64("${var.zscaler_cc_function_file_path}")
  filename       = "${path.module}/zscaler_cc_function_app_${random_string.function_app_hash[0].result}.zip"
}

locals {
  website_run_from_pkg = var.zscaler_cc_function_deploy_local_file ? "1" : var.zscaler_cc_function_public_url
}

resource "azurerm_linux_function_app" "orchestration_app" {
  name                = "${var.name_prefix}-ccvmss-${var.resource_tag}-function-app"
  resource_group_name = var.resource_group
  location            = var.location

  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.app_service_plan.id
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  zip_deploy_file = var.zscaler_cc_function_deploy_local_file ? "${path.module}/zscaler_cc_function_app_${random_string.function_app_hash[0].result}.zip" : null
  app_settings    = { "SUBSCRIPTION_ID" = var.susbcription_id, "MANAGED_IDENTITY" = var.managed_identity_client_id, "RESOURCE_GROUP" = var.resource_group, "VMSS_NAME" = azurerm_orchestrated_virtual_machine_scale_set.cc_vmss.name, "TERMINATE_UNHEALTHY_INSTANCES" = var.terminate_unhealthy_instances, "VAULT_URL" = var.vault_url, "CC_URL" = var.cc_vm_prov_url, "WEBSITE_RUN_FROM_PACKAGE" = local.website_run_from_pkg, "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.orchestration_app_insights.connection_string }

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }
}
