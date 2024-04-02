locals {
  team     = "dibbs"
  project  = "ce"
  env      = "global"
  location = "eastus"

  resource_group_name = "${local.team}-${local.project}-${local.env}"
}

resource "azurerm_key_vault" "kv" {
  name                        = "${local.team}${local.project}${local.env}kv"
  location                    = local.location
  resource_group_name         = local.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

module "octopus_service" {
  source   = "../resources/app_service"
  team     = local.team
  project  = local.project
  env      = local.env
  location = local.location

  resource_group_name = local.resource_group_name

  tenant_id    = data.azurerm_client_config.current.tenant_id
  key_vault_id = azurerm_key_vault.kv.id

  webapp_subnet_id = azurerm_subnet.webapp.id
}


module "sql_server" {
  source = "../resources/sql_database"
  team     = local.team
  project  = local.project
  env      = local.env
  location = local.location

  resource_group_name = local.resource_group_name
}