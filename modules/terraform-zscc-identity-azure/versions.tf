terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 3.108.0, <= 3.116"
      configuration_aliases = [azurerm.managed_identity_sub]
    }
  }
  required_version = ">= 0.13.7, < 2.0.0"
}
