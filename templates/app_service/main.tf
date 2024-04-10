locals {
  name = "${var.team}-${var.project}-${var.env}"
}

resource "azurerm_service_plan" "service" {
  name                = "${local.name}-service-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "service" {
  name                = "${local.name}-service-octopus"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.service.id
  app_settings = {
    "WEBSITES_CONTAINER_START_TIME_LIMIT" = "1200" //Adjust this value to control the timeout of your container's startup window
  }

  site_config {
    application_stack {
      docker_image_name   = "octopusdeploy/octopusdeploy:2024.1" //Change this image name to suit your needs.
      docker_registry_url = "https://index.docker.io"            //Modify this to suit the registry your image is being pulled from. This can also be your own ACR instance.
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "app_secret_access" {
  key_vault_id = var.key_vault_id
  object_id    = azurerm_linux_web_app.service.identity[0].principal_id
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
  app_service_id = azurerm_linux_web_app.service.id
  subnet_id      = var.webapp_subnet_id
}