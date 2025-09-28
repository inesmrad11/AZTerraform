terraform {
    backend "azurerm" {
        resource_group_name  = "terraform-state-rg-ines"
        storage_account_name = "tfdevbackend2025ines"
        container_name       = "tfstate"
        key                  = "ines-dev.tfstate"
    }
}

provider "azurerm" {
  features {}
}