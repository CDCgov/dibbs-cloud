locals {
  name = "${var.team}-${var.project}-${var.env}"
}

# Create the virtual network and the persistent subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.name}-network"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.network_address]
}

resource "azurerm_subnet" "lbs" {
  name                 = "${local.name}-lb"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.network_address, 8, 254)] # X.X.254.0/24
  service_endpoints = [
    "Microsoft.Web",
    "Microsoft.Storage"
  ]
}

/*
# Subnet for App Service Plans
resource "azurerm_subnet" "webapp" {
  name                 = "${local.name}-webapp"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = [cidrsubnet(var.network_address, 8, 100)] # X.X.100.0/24

  delegation {
    name = "serverfarms"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}
*/

/*
# Subnet + network profile for Azure Container Instances
resource "azurerm_subnet" "container_instances" {
  name                 = "${var.env}-azure-container-instances"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = [cidrsubnet(var.network_address, 8, 101)] # X.X.101.0/24

  delegation {
    name = "${var.env}-container-instances"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_profile" "container_instances" {
  name                = "${var.env}-azure-container-instances"
  location            = var.location
  resource_group_name = var.resource_group_name

  container_network_interface {
    name = "${var.env}-container-instances"

    ip_configuration {
      name      = "${var.env}-container-instances"
      subnet_id = azurerm_subnet.container_instances.id
    }
  }
}
*/

/*
# Subnet for Flexible DBs
resource "azurerm_subnet" "db" {
  name                 = "${var.env}-db"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = [cidrsubnet(var.network_address, 8, 102)] # X.X.102.0/24

  delegation {
    name = "${var.env}-db"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# The name of the private DNS zone MUST be environment-specific to support multiple envs within the same resource group.
resource "azurerm_private_dns_zone" "default" {
  name                = "privatelink.${var.env == var.env_level ? "" : "${var.env}."}postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

# DNS/VNet linkage for Flexible DB functionality
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "${var.env}-vnet-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  virtual_network_id    = azurerm_virtual_network.vn.id
}
*/
