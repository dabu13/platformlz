terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate10630st"
    container_name       = "aks"
    key                  = "platformlz/terraform.tfstate"
  }
}
