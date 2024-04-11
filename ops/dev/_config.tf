terraform {
  backend "azurerm" {
    resource_group_name  = "dibbs-ce-global"
    storage_account_name = "dibbsglobalstatestorage"
    container_name       = "ce-tfstate"
    key                  = "dev/terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.93.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "= 1.12.1"
    }
  }
  required_version = "~> 1.7.4"
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

provider "azapi" {}