## Terraform state backend configuration. Uncomment and populate to use a remote backend.
## See https://developer.hashicorp.com/terraform/language/settings/backends/azurerm for details.

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "StorageAccount-ResourceGroup"
#     storage_account_name = "abcd1234"
#     container_name       = "tfstate"
#     key                  = "cc_public_lb.terraform.tfstate"
#   }
# }
