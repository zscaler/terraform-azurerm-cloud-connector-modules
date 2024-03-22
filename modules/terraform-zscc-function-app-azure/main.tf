################################################################################
# Create Function App Dependencies
################################################################################
# Create Storage Account to store Function App
resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.resource_tag}storage"
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.name_prefix}-ccvmss-${var.resource_tag}-app-service-plan"
  resource_group_name = var.resource_group
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

# Create Application Insights resource
resource "azurerm_application_insights" "vmss_orchestration_app_insights" {
  name                = "${var.name_prefix}-ccvmss-${var.resource_tag}-app-insights"
  location            = var.location
  resource_group_name = var.resource_group
  application_type    = "web"
}

/*
data "local_file" "zscaler_function_app_file" {
  count    = var.zscaler_cc_function_deploy_local_file ? 1 : 0
  filename = "${path.module}/zscaler_cc_function_app.zip"
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
*/

################################################################################
# Create Function App
################################################################################
resource "azurerm_linux_function_app" "vmss_orchestration_app" {
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

  zip_deploy_file = var.zscaler_cc_function_deploy_local_file ? "${path.module}/zscaler_cc_function_app.zip" : null

  app_settings = merge(var.cc_function_app_settings, { "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.vmss_orchestration_app_insights.connection_string, "WEBSITE_RUN_FROM_PACKAGE" = var.zscaler_cc_function_deploy_local_file ? "1" : var.zscaler_cc_function_public_url })

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  tags = var.global_tags
}
