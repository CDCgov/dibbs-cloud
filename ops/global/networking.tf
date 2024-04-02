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
    name = "serverfarms"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

# Create private endpoint for SQL server
resource "azurerm_private_endpoint" "my_terraform_endpoint" {
  name                = "private-endpoint-sql"
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = azurerm_subnet.webapp.id

  private_service_connection {
    name                           = "private-serviceconnection"
    private_connection_resource_id = module.sql_server.sql_server_id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.my_terraform_dns_zone.id]
  }
}

# Create private DNS zone
resource "azurerm_private_dns_zone" "my_terraform_dns_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = local.resource_group_name
}

# Create virtual network link
resource "azurerm_private_dns_zone_virtual_network_link" "my_terraform_vnet_link" {
  name                  = "vnet-link"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.my_terraform_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}