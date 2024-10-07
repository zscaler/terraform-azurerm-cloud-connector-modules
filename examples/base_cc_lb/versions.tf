terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.108.0, <= 3.116"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.4.0"
    }
  }
  required_version = ">= 0.13.7, < 2.0.0"
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "managed_identity_sub"
  subscription_id = var.managed_identity_subscription_id == null ? var.env_subscription_id : var.managed_identity_subscription_id
  features {}
  skip_provider_registration = true
}
