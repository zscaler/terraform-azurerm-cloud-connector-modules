################################################################################
# Create Cloud Connector VMSS
################################################################################
# Create VMSS
resource "azurerm_orchestrated_virtual_machine_scale_set" "cc_vmss" {
  count                       = local.zones_supported ? length(var.zones) : 1
  name                        = "${var.name_prefix}-ccvmss-${count.index + 1}-${var.resource_tag}"
  location                    = var.location
  resource_group_name         = var.resource_group
  platform_fault_domain_count = var.fault_domain_count
  sku_name                    = var.ccvm_instance_type
  encryption_at_host_enabled  = var.encryption_at_host_enabled
  zones                       = local.zones_supported ? [element(var.zones, count.index)] : null
  zone_balance                = false
  user_data_base64            = base64encode(var.user_data)
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
      subnet_id = element(var.mgmt_subnet_id, count.index)
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
      subnet_id                              = element(var.service_subnet_id, count.index)
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

  dynamic "source_image_reference" {
    for_each = var.ccvm_source_image_id == null ? [var.ccvm_image_publisher] : []

    content {
      publisher = var.ccvm_image_publisher
      offer     = var.ccvm_image_offer
      sku       = var.ccvm_image_sku
      version   = var.ccvm_image_version
    }
  }

  dynamic "plan" {
    for_each = var.ccvm_source_image_id == null ? [var.ccvm_image_publisher] : []

    content {
      publisher = var.ccvm_image_publisher
      name      = var.ccvm_image_sku
      product   = var.ccvm_image_offer
    }
  }

  source_image_id = var.ccvm_source_image_id != null ? var.ccvm_source_image_id : null

  tags = var.global_tags

  depends_on = [
    var.backend_address_pool
  ]
}


# Create scaleset profiles and thresholds
resource "azurerm_monitor_autoscale_setting" "vmss_autoscale_setting" {
  count               = length(azurerm_orchestrated_virtual_machine_scale_set.cc_vmss[*].id)
  name                = "custom-scale-rule-az-${count.index + 1}"
  resource_group_name = var.resource_group
  location            = var.location
  target_resource_id  = element(azurerm_orchestrated_virtual_machine_scale_set.cc_vmss[*].id, count.index)

  profile {
    name = "defaultProfile"

    capacity {
      default = var.vmss_default_ccs
      minimum = var.vmss_min_ccs
      maximum = var.vmss_max_ccs
    }

    rule {
      metric_trigger {
        metric_name = "smedge_metrics"
        dimensions {
          name     = "metric_name"
          operator = "Equals"
          values   = ["smedge_cpu_utilization"]
        }
        metric_resource_id = element(azurerm_orchestrated_virtual_machine_scale_set.cc_vmss[*].id, count.index)
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = var.scale_out_evaluation_period
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.scale_out_threshold
        metric_namespace   = "Zscaler/CloudConnectors"
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
        metric_name = "smedge_metrics"
        dimensions {
          name     = "metric_name"
          operator = "Equals"
          values   = ["smedge_cpu_utilization"]
        }
        metric_resource_id = element(azurerm_orchestrated_virtual_machine_scale_set.cc_vmss[*].id, count.index)
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = var.scale_in_evaluation_period
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.scale_in_threshold
        metric_namespace   = "Zscaler/CloudConnectors"
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
          metric_name = "smedge_metrics"
          dimensions {
            name     = "metric_name"
            operator = "Equals"
            values   = ["smedge_cpu_utilization"]
          }
          metric_resource_id = element(azurerm_orchestrated_virtual_machine_scale_set.cc_vmss[*].id, count.index)
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = var.scale_out_evaluation_period
          time_aggregation   = "Average"
          operator           = "GreaterThan"
          threshold          = var.scale_out_threshold
          metric_namespace   = "Zscaler/CloudConnectors"
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
          metric_name = "smedge_metrics"
          dimensions {
            name     = "metric_name"
            operator = "Equals"
            values   = ["smedge_cpu_utilization"]
          }
          metric_resource_id = element(azurerm_orchestrated_virtual_machine_scale_set.cc_vmss[*].id, count.index)
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = var.scale_in_evaluation_period
          time_aggregation   = "Average"
          operator           = "LessThan"
          threshold          = var.scale_in_threshold
          metric_namespace   = "Zscaler/CloudConnectors"
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

  tags = var.global_tags
}
