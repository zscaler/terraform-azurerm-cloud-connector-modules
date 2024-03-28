################################################################################
# Get current Subscription ID
################################################################################
data "azurerm_subscription" "current" {
}

################################################################################
# Create Function App Dependencies
################################################################################
# Create Storage Account to store Function App
resource "azurerm_storage_account" "cc_function_storage_account" {
  count                    = var.existing_storage_account ? 0 : 1
  name                     = "stccvmss${var.resource_tag}"
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

data "azurerm_storage_account" "existing_storage_account" {
  count               = var.existing_storage_account ? 1 : 0
  name                = var.existing_storage_account_name
  resource_group_name = var.existing_storage_account_rg
}

locals {
  storage_account_name       = var.existing_storage_account ? data.azurerm_storage_account.existing_storage_account[0].name : azurerm_storage_account.cc_function_storage_account[0].name
  storage_account_id         = var.existing_storage_account ? data.azurerm_storage_account.existing_storage_account[0].id : azurerm_storage_account.cc_function_storage_account[0].id
  storage_account_access_key = var.existing_storage_account ? data.azurerm_storage_account.existing_storage_account[0].primary_access_key : azurerm_storage_account.cc_function_storage_account[0].primary_access_key
}

# Create Private Storage Container to upload function zip file
resource "azurerm_storage_container" "cc_function_storage_container" {
  count                 = var.upload_function_app_zip ? 1 : 0
  name                  = "function-zip-container"
  storage_account_name  = local.storage_account_name
  container_access_type = "private"
}

# Create Storage Blob to store function zip file
resource "azurerm_storage_blob" "cc_function_storage_blob" {
  count                  = var.upload_function_app_zip ? 1 : 0
  name                   = "zscaler_cc_function_app.zip"
  storage_account_name   = local.storage_account_name
  storage_container_name = azurerm_storage_container.cc_function_storage_container[0].name
  type                   = "Block"
  source                 = "${path.module}/zscaler_cc_function_app.zip"
  content_md5            = filemd5("${path.module}/zscaler_cc_function_app.zip")
}

# Restrict storage account blob access to only CC/Function App Managed Identity
resource "azurerm_role_assignment" "cc_function_role_assignment_storage" {
  count                = var.upload_function_app_zip ? 1 : 0
  scope                = local.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.managed_identity_principal_id
}

# Create App Service Plan
resource "azurerm_service_plan" "vmss_orchestration_app_service_plan" {
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


################################################################################
# Create Function App
################################################################################
resource "azurerm_linux_function_app" "vmss_orchestration_app" {
  name                = "${var.name_prefix}-ccvmss-${var.resource_tag}-function-app"
  resource_group_name = var.resource_group
  location            = var.location

  storage_account_name       = local.storage_account_name
  storage_account_access_key = local.storage_account_access_key
  service_plan_id            = azurerm_service_plan.vmss_orchestration_app_service_plan.id

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  app_settings = {
    "SUBSCRIPTION_ID"                              = data.azurerm_subscription.current.id
    "MANAGED_IDENTITY"                             = var.managed_identity_client_id
    "RESOURCE_GROUP"                               = var.resource_group
    "VMSS_NAME"                                    = jsonencode(var.vmss_names)
    "TERMINATE_UNHEALTHY_INSTANCES"                = var.terminate_unhealthy_instances
    "VAULT_URL"                                    = var.azure_vault_url
    "CC_URL"                                       = var.cc_vm_prov_url
    "APPLICATIONINSIGHTS_CONNECTION_STRING"        = azurerm_application_insights.vmss_orchestration_app_insights.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION"   = "~3"
    "XDT_MicrosoftApplicationInsights_Mode"        = "recommended"
    "WEBSITE_RUN_FROM_PACKAGE"                     = var.upload_function_app_zip ? azurerm_storage_blob.cc_function_storage_blob[0].url : var.zscaler_cc_function_public_url
    "WEBSITE_RUN_FROM_PACKAGE_BLOB_MI_RESOURCE_ID" = var.managed_identity_id
  }

  site_config {
    application_stack {
      python_version = "3.11"
    }
    application_insights_connection_string = azurerm_application_insights.vmss_orchestration_app_insights.connection_string
  }

  lifecycle {
    ignore_changes = [
      app_settings["APPLICATIONINSIGHTS_CONNECTION_STRING"],
    ]
  }

  tags = var.global_tags
}
