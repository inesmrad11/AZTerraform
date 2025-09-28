terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg-ines"
    storage_account_name = "tfstagebackend2025ines"
    container_name      = "tfstate"
    key                 = "stage.tfstate"
  }
}

provider "azurerm" {
  features {}
}