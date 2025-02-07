terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.108.0, <= 3.116"
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
