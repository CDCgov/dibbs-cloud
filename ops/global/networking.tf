locals {
  name = "${local.team}-${local.project}-${local.env}"
}

# Create the virtual network and the persistent subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.name}-network"
  resource_group_name = local.resource_group_name
  location            = local.location
  address_space       = ["10.30.0.0/16"]
}

resource "azurerm_subnet" "webapp" {
  name                 = "${local.name}-webapp"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.30.7.0/24"]

  delegation {
    name = "webapp-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  service_endpoints = [ "Microsoft.Web", "Microsoft.SQL" ]
}

resource "azurerm_subnet" "db" {
  name                 = "${local.name}-db"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.30.9.0/24"]
}


# Create private endpoint for SQL server
resource "azurerm_private_endpoint" "sql_endpoint" {
  name                = "${local.env}.private-endpoint-sql"
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = azurerm_subnet.db.id

  private_service_connection {
    name                           = "${local.env}-private-serviceconnection"
    private_connection_resource_id = module.sql_server.sql_server_id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.database_dns_zone.id]
  }
}
/*
resource "azurerm_private_endpoint" "sql_app_endpoint" {
  name                = "${local.env}.private-endpoint-webapp"
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = azurerm_subnet.webapp.id

  private_service_connection {
    name                           = "${local.env}-private-serviceconnection"
    private_connection_resource_id = module.sql_server.sql_server_id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.database_dns_zone.id]
  }
}*/

# Create private DNS zone
resource "azurerm_private_dns_zone" "database_dns_zone" {
  name                = "${local.env}.privatelink.database.windows.net"
  resource_group_name = local.resource_group_name
}

# Create virtual network link
resource "azurerm_private_dns_zone_virtual_network_link" "database_vnet_link" {
  name                  = "${local.env}-vnet-link"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.database_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}