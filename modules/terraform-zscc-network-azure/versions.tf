terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.9.0, < 5.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  required_version = ">= 0.13.7, < 2.0.0"
}
