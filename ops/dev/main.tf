locals {
  team     = "dibbs"
  project  = "ce"
  env      = "dev"
  location = "eastus"
}

module "foundations" {
  source   = "../resources/foundations"
  team     = local.team
  project  = local.project
  env      = local.env
  location = local.location
}

module "virtual_network" {
  source                = "../resources/virtual_network"
  team                  = local.team
  project               = local.project
  env                   = local.env
  location              = local.location
  resource_group_name   = module.foundations.resource_group_name
  network_address_space = "10.30.0.0/16"
}

module "aks" {
  source              = "../resources/aks_cluster"
  team                = local.team
  project             = local.project
  env                 = local.env
  location            = local.location
  resource_group_name = module.foundations.resource_group_name

  aks_subnet_id = module.virtual_network.subnet_kube_id
  agic_id       = module.virtual_network.agic_id

  key_vault_id = module.foundations.key_vault_id
}

module "container_apps" {
  source                = "../resources/aca"
  team                  = local.team
  project               = local.project
  env                   = local.env
  location              = local.location
  resource_group_name   = module.foundations.resource_group_name

  publisher_name        = "" # Add the missing attribute "publisher_name" here
  publisher_email       = "" # Add the missing attribute "publisher_email" here

  key_vault_id          = module.foundations.key_vault_id

  aca_subnet_id         = module.virtual_network.subnet_aca_id
  vnet_name             = module.virtual_network.network.name

  acr_url               = module.foundations.acr_url
  acr_username          = module.foundations.acr_admin_username //TODO: Change to an ACA-specific password
  acr_password          = module.foundations.acr_admin_password //TODO: Change to an ACA-specific password

}