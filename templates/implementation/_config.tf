terraform {
  backend "azurerm" {
    resource_group_name  = "#{vars.rg_name}"
    storage_account_name = "#{vars.sa_name}"
    container_name       = "#{vars.container_name}"
    key                  = "#{vars.env}/terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.93.0"
    }
  }
  required_version = "~> 1.7.4"
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}