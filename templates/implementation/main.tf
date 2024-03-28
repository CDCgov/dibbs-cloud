locals {
  team     = "#{vars.team}"
  project  = "#{vars.project}"
  env      = "#{vars.env}"
  location = "#{vars.location}"
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
  network_address     = "x.x.x.x/xx"
}