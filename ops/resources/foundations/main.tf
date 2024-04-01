resource "azurerm_resource_group" "rg" {
  name     = "${var.team}-${var.project}-${var.env}"
  location = var.location
}

data "azurerm_client_config" "current" {}

locals {
  current_user_id = coalesce(var.msi_id, data.azurerm_client_config.current.object_id)
}

#tfsec:ignore:azure-keyvault-specify-network-acl:exp:2024-04-01
resource "azurerm_key_vault" "kv" {
  name     = "${var.team}${var.project}${var.env}kv"
  location = azurerm_resource_group.rg.location
  #resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  # Without an network ACL the key vault is freely accesible
  # See https://aquasecurity.github.io/tfsec/v1.0.7/checks/azure/keyvault/specify-network-acl/
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = local.current_user_id

    # key_permissions    = var.key_permissions
    # secret_permissions = var.secret_permissions
  }
}

resource "azurerm_container_registry" "acr" {
  location            = azurerm_resource_group.rg.location
  name                = "${var.team}${var.project}${var.env}acr"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_storage_account" "app" {
  account_replication_type         = "GRS" # Cross-regional redundancy
  account_tier                     = "Standard"
  account_kind                     = "StorageV2"
  name                             = "${var.team}${var.project}${var.env}sa"
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = azurerm_resource_group.rg.location
  enable_https_traffic_only        = true
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
}