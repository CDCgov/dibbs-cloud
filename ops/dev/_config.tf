terraform {
  backend "azurerm" {
    resource_group_name  = "dibbs-ce-dev"
    storage_account_name = "dibbsglobalstatestorage"
    container_name       = "ce-tfstate"
    key                  = "stg/terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.93.0"
    }
  }
  required_version = "~> 1.7.3"
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}