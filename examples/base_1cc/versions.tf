terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.99.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  required_version = ">= 0.13"
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias  = "managed_identity_sub"
  subscription_id = var.managed_identity_subscription_id == null ? var.env_subscription_id : var.managed_identity_subscription_id
  features {}
  skip_provider_registration = true
}