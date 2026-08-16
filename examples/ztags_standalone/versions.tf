terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.9.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.2.0"
    }
  }
  required_version = ">= 0.13.7, < 2.0.0"
}

provider "azurerm" {
  features {}
}

provider "azapi" {
}
