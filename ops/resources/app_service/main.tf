resource "azurerm_service_plan" "octopus" {
  name                = "example"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "octopus" {
  name                = "example"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.octopus.id

  site_config {
    application_stack {
      docker_image_name = "octopusdeploy/octopusdeploy:2024.1"

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