locals {
  project   = "#{vars.project}"
  name      = "#{vars.name}"
  env       = "#{vars.env}"

  network_cidr = "10.1.0.0/16"
  rg_name      = data.azurerm_resource_group.name
  rg_location  = data.azurerm_resource_group.location
  management_tags = {
    environment    = local.env
    resource_group = "${local.project}-${local.name}-${local.env}"
  }
}

module "vnet" {
  source              = "../../services/virtual_network"
  env                 = local.env
  resource_group_name = local.rg_name
  network_address     = local.network_cidr
  management_tags     = local.management_tags
  location            = local.rg_location
}