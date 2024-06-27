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
  source              = "../resources/aca"
  team                = local.team
  project             = local.project
  env                 = local.env
  location            = local.location
  resource_group_name = module.foundations.resource_group_name

  key_vault_id = module.foundations.key_vault_id

  aca_subnet_id = module.virtual_network.subnet_aca_id
}