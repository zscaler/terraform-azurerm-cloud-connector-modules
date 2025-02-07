################################################################################
# Create Resource Group
################################################################################
resource "azurerm_resource_group" "zs_tags_rg" {
  count    = var.resource_group_name != null ? 0 : 1
  name     = "${var.name_prefix}-zs-tagging-service-${var.resource_tag}"
  location = var.location

  tags = var.global_tags
}

# Or reference an existing Resource Group
data "azurerm_resource_group" "existing_zs_tags_rg" {
  count = var.resource_group_name != null ? 1 : 0
  name  = var.resource_group_name
}

################################################################################
# Create Event Grid System Topic 
################################################################################

data "azurerm_subscription" "current_subscription" {
}

locals {
  selected_subscription_id = coalesce(var.subscription_id, data.azurerm_subscription.current_subscription.subscription_id)
}

# System topics are created globally (applies across all regions in a given subscription)
resource "azapi_resource" "zs_system_topic" {
  parent_id = var.resource_group_name != null ? data.azurerm_resource_group.existing_zs_tags_rg[0].id : azurerm_resource_group.zs_tags_rg[0].id
  type      = "Microsoft.EventGrid/systemTopics@2021-12-01"
  name      = "${var.name_prefix}-zs-system-topic-${var.resource_tag}"
  location  = "Global"
  body = {
    properties = {
      source    = "/subscriptions/${local.selected_subscription_id}"
      topicType = "Microsoft.ResourceNotifications.Resources"
    }
  }
  tags = var.global_tags
}


################################################################################
# Create Event Subscription towards existing PartnerDestination
################################################################################

resource "azapi_resource" "zs_event_subscription" {
  parent_id = azapi_resource.zs_system_topic.id
  type      = "Microsoft.EventGrid/systemTopics/eventSubscriptions@2024-12-15-preview"
  name      = "${var.name_prefix}-zs-event-sub-${var.resource_tag}"
  body = {
    properties = {
      destination = {
        endpointType = "PartnerDestination"
        properties = {
          resourceId = var.partnerdestination_id
        }
      }
      eventDeliverySchema = "CloudEventSchemaV1_0"
      filter = {
        includedEventTypes = [
          "Microsoft.ResourceNotifications.Resources.CreatedOrUpdated"
        ]
      }
    }
  }
}
