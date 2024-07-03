locals {
  name = "${var.team}-${var.project}-${var.env}"

  orchestration_backend_pool                = "${local.name}-be-orchestration"
  orchestration_backend_http_setting        = "${local.name}-be-orchestration-http"
  orchestration_backend_https_setting       = "${local.name}-be-orchestration-https"
  metabase_pool                   = "${local.name}-be-metabase"
  metabase_http_setting           = "${local.name}-be-api-metabase-http"
  metabase_https_setting          = "${local.name}-be-api-metabase-https"

  building_block_definitions = {
    fhir-converter = {
      name   = "fhir-converter"
      cpu    = 0.5
      memory = "1Gi"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"

      is_public = false
    }
    ingestion = {
      name   = "ingestion"
      cpu    = 0.5
      memory = "1Gi"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"

      is_public = false
    }
    message-parser = {
      name   = "message-parser"
      cpu    = 0.5
      memory = "1Gi"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"

      is_public = false
    }
    orchestration = {
      name   = "orchestration"
      cpu    = 0.5
      memory = "1Gi"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"

      is_public = true

      path_rule = {
        name                       = "orchestration"
        paths                      = ["/api/*", "/api"]
        backend_address_pool_name  = local.orchestration_backend_pool
        backend_http_settings_name = local.orchestration_backend_https_setting
        // this is the default, why would we set it again?
        // because if we don't do this we get 404s on API calls
        rewrite_rule_set_name = "orchestration-routing"
      }
    }
    validation = {
      name   = "validation"
      cpu    = 0.5
      memory = "1Gi"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"

      is_public = false
    }
    tefca-viewer = {
      name   = "tefca-viewer"
      cpu    = 0.5
      memory = "1Gi"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"

      is_public = false
    }
    message-refiner = {
      name   = "message-refiner"
      cpu    = 0.5
      memory = "1Gi"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"

      is_public = false
    }
    trigger-code-reference = {
      name   = "trigger-code-reference"
      cpu    = 0.5
      memory = "1Gi"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"

      is_public = false
    }
    ecr-viewer = {
      name   = "ecr-viewer"
      cpu    = 0.5
      memory = "1Gi"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"

      is_public = true

      path_rule = {
        name                       = "api"
        paths                      = ["/api/*", "/api"]
        backend_address_pool_name  = local.orchestration_backend_pool
        backend_http_settings_name = local.orchestration_backend_https_setting
        // this is the default, why would we set it again?
        // because if we don't do this we get 404s on API calls
        rewrite_rule_set_name = "orchestration-routing"
      }
    }
    record-linkage = {
      name   = "record-linkage"
      cpu    = 0.5
      memory = "1Gi"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"

      is_public = false
    }
  }
}

resource "azurerm_log_analytics_workspace" "aca_analytics" {
  name                = "${local.name}-aca-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  daily_quota_gb = 5
}

resource "azurerm_container_app_environment" "ce_apps" {
  name                       = "${local.name}-apps"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aca_analytics.id

  infrastructure_resource_group_name = "${local.name}-apps-rg"
  infrastructure_subnet_id           = var.aca_subnet_id

  //Can create additional profiles for FHIR converter, etc.
  workload_profile {
    name                  = "${local.name}-apps-profile"
    workload_profile_type = "D4"
    maximum_count         = 10
    minimum_count         = 1
  }
}

variable "services" {
  type = list(string)
  default = ["fhir-converter",
    "ingestion",
    "message-parser",
    "orchestration",
    "validation",
    "tefca-viewer",
    "message-refiner",
    "trigger-code-reference",
    "ecr-viewer",
  "record-linkage"]
}

resource "azurerm_container_app" "aca_apps" {
  for_each = local.building_block_definitions

  name                         = each.value.name
  container_app_environment_id = azurerm_container_app_environment.ce_apps.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  /*template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }*/

  template {
    container {
      name   = each.value.name
      image  = each.value.image
      cpu    = each.value.cpu
      memory = each.value.memory
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server               = var.acr_url
    username             = var.acr_username
    password_secret_name = "acr-password-secret"
    //TODO: change the above to a key vault reference.
  }

  secret {
    name  = "acr-password-secret"
    value = "var.acr_password"
  } //TODO: Delete this in favor of key vault reference?

  workload_profile_name = "${local.name}-apps-profile"
}