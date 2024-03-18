locals {
  name = "${var.team}-${var.project}-${var.env}"
}

# Create the virtual network and the persistent subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.name}-network"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.network_address_space]
}

resource "azurerm_subnet" "appgw" {
  name                 = "${local.name}-appgw-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.app_gateway_subnet_address_prefix]
  service_endpoints = [
    "Microsoft.Web",
    "Microsoft.Storage"
  ]
}

resource "azurerm_subnet" "lbs" {
  name                 = "${local.name}-lb"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.lb_subnet_address_prefix]
  service_endpoints = [
    "Microsoft.Web",
    "Microsoft.Storage"
  ]
}
