terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.99.0"
    }
  }
  required_version = ">= 0.13.7, < 2.0.0"
}
