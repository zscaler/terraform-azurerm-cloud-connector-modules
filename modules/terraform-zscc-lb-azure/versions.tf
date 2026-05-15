terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.108.0, < 5.0.0"
    }
  }
  required_version = ">= 0.13.7, < 2.0.0"
}
