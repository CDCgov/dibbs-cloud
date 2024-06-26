locals {
  name           = "${var.team}-${var.project}-${var.env}"
  octopus_mounts = ["repository", "artifacts", "tasklogs", "cache", "import"]
}

resource "azurerm_service_plan" "octopus" {
  name                = "${local.name}-octopus-service-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "octopus" {
  name                = "${local.name}-octopus"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.octopus.id
  app_settings = {
    "ACCEPT_EULA"                         = "Y"
    "ACCEPT_OCTOPUS_EULA"                 = "Y"
    "OCTOPUS_SERVER_NODE_NAME"            = "${local.name}-octopus"
    "DB_CONNECTION_STRING"                = "Server=tcp:${local.name}-octopus-sqlserver.database.windows.net,1433;Initial Catalog=octopus-db;Persist Security Info=False;User ID=${data.azurerm_key_vault_secret.db_username.value};Password=${data.azurerm_key_vault_secret.db_password.value};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    "ADMIN_USERNAME"                      = "${data.azurerm_key_vault_secret.octopus_admin_username.value}"
    "ADMIN_PASSWORD"                      = "${data.azurerm_key_vault_secret.octopus_admin_password.value}"
    "ADMIN_EMAIL"                         = ""
    "MASTER_KEY"                          = "${data.azurerm_key_vault_secret.octopus_master_key.value}"
    "DISABLE_DIND"                        = "true"
    "TASK_CAP"                            = "5"
    "SA_PASSWORD"                         = data.azurerm_key_vault_secret.db_password.value
    "WEBSITES_CONTAINER_START_TIME_LIMIT" = "1200"
  }

  virtual_network_subnet_id = var.webapp_subnet_id

  site_config {
    application_stack {
      docker_image_name   = "dibbs-cloud/octopusdeploy:${var.octopus_image_version}"
      docker_registry_url = "https://${var.acr_url}"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "storage_account" {
    for_each = local.octopus_mounts

    content {
      name         = storage_account.value
      account_name = var.storage_account_name
      access_key   = var.storage_account_key
      share_name   = storage_account.value
      mount_path   = "/${storage_account.value}"
      type         = "AzureFiles"
    }
  }
}

resource "azurerm_key_vault_access_policy" "app_secret_access" {
  key_vault_id = var.key_vault_id
  object_id    = azurerm_linux_web_app.octopus.identity[0].principal_id
  tenant_id    = var.tenant_id

  key_permissions = [
    "Get",
    "List",
  ]
  secret_permissions = [
    "Get",
    "List",
  ]
}

resource "azurerm_app_service_virtual_network_swift_connection" "app" {
  app_service_id = azurerm_linux_web_app.octopus.id
  subnet_id      = var.webapp_subnet_id
}