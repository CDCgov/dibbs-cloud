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

module "app_service" {
  source   = "../resources/app_service"
  team     = local.team
  project  = local.project
  env      = local.env
  location = local.location

  resource_group_name = local.resource_group_name

  tenant_id    = data.azurerm_client_config.current.tenant_id
  key_vault_id = module.foundations.key_vault_id

  webapp_subnet_id = module.virtual_network.subnet_lbs_id

  // If your service has a database dependency, use the following meta argument to
  // ensure the database is created before the service.
  depends_on = [module.sql_server]
}

module "sql_server" {
  source   = "../resources/sql_database"
  team     = local.team
  project  = local.project
  env      = local.env
  location = local.location

  resource_group_name = local.resource_group_name
  global_vault_id     = module.foundations.key_vault_id
  administrator_login = "admin"
  webapp_subnet_id    = module.virtual_network.subnet_lbs_id
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
}