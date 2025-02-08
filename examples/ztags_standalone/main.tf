################################################################################
# Generate a unique random string for resource name assignment and key pair
################################################################################
resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}


################################################################################
# Map default tags with values to be assigned to all tagged resources
################################################################################
locals {
  global_tags = {
    Owner       = var.owner_tag
    ManagedBy   = "terraform"
    Vendor      = "Zscaler"
    Environment = var.environment
  }
}

################################################################################
# 1. Create Event Grid resources for Zscaler Tag Discovery Service
################################################################################
module "ztags" {
  source                = "../../modules/terraform-zscc-ztags-azure"
  name_prefix           = var.name_prefix
  resource_tag          = random_string.suffix.result
  global_tags           = local.global_tags
  location              = var.arm_location
  partnerdestination_id = var.partnerdestination_id
  resource_group_name   = var.existing_ztags_rg_name
  subscription_id       = var.subscription_id
}
