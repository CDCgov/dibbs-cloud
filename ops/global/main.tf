locals {
  team     = "dibbs"
  project  = "ce"
  env      = "global"
  location = "eastus"

  resource_group_name = "${local.team}-${local.project}-${local.env}"
}

#tfsec:ignore:azure-keyvault-specify-network-acl:exp:2024-05-01
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

resource "azurerm_container_registry" "acr" {
  location            = local.location
  name                = "${local.team}${local.project}${local.env}acr"
  resource_group_name = local.resource_group_name
  sku                 = "Standard"
  admin_enabled       = true
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

  storage_account_name = azurerm_storage_account.app.name
  storage_account_key  = azurerm_storage_account.app.primary_access_key

  acr_url = azurerm_container_registry.acr.login_server
  acr_username = azurerm_container_registry.acr.admin_username
  acr_password = azurerm_container_registry.acr.admin_password
  octopus_image_version = var.acr_image_tag

  depends_on = [module.sql_server, azurerm_storage_share.repository, azurerm_storage_share.artifacts, azurerm_storage_share.tasklogs, azurerm_storage_share.cache, azurerm_storage_share.import, azurerm_storage_share.eventExports]
}


module "sql_server" {
  source   = "../resources/sql_database"
  team     = local.team
  project  = local.project
  env      = local.env
  location = local.location

  resource_group_name = local.resource_group_name
  global_vault_id     = azurerm_key_vault.kv.id
  administrator_login = "octopus_admin"
  webapp_subnet_id    = azurerm_subnet.webapp.id

  primary_access_key    = azurerm_storage_account.app.primary_access_key
  primary_blob_endpoint = azurerm_storage_account.app.primary_blob_endpoint

  depends_on = [azurerm_storage_account.app]
}
