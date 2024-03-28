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
  source              = "../resources/virtual_network"
  team                = local.team
  project             = local.project
  env                 = local.env
  location            = local.location
  resource_group_name = module.foundations.resource_group_name
  network_address     = "10.30.0.0/16"
}

module "aks" {
  source              = "../resources/aks"
  resource_group_name = module.foundations.resource_group_name
  team                = local.team
  project             = local.project
  env                 = local.env
  location            = local.location
  public_key          = local.public_key
}