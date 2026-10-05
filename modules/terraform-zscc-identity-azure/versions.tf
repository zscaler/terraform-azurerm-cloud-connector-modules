terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 4.9.0, < 5.0.0"
      configuration_aliases = [azurerm.managed_identity_sub]
    }
  }
  required_version = ">= 1.4.0, < 2.0.0"
}
