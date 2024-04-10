resource "azurerm_storage_account" "app" {
  account_replication_type         = "GRS" # Cross-regional redundancy
  account_tier                     = "Standard"
  account_kind                     = "StorageV2"
  name                             = "${local.team}${local.project}${local.env}sa"
  resource_group_name              = local.resource_group_name
  location                         = local.location
  enable_https_traffic_only        = true
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
}

resource "azurerm_storage_share" "repository" {
  name                 = "repository"
  storage_account_name = azurerm_storage_account.app.name
  quota                = 5
}

resource "azurerm_storage_share" "artifacts" {
  name                 = "artifacts"
  storage_account_name = azurerm_storage_account.app.name
  quota                = 5
}

resource "azurerm_storage_share" "tasklogs" {
  name                 = "tasklogs"
  storage_account_name = azurerm_storage_account.app.name
  quota                = 5
}

resource "azurerm_storage_share" "cache" {
  name                 = "cache"
  storage_account_name = azurerm_storage_account.app.name
  quota                = 5
}

resource "azurerm_storage_share" "import" {
  name                 = "import"
  storage_account_name = azurerm_storage_account.app.name
  quota                = 5
}

resource "azurerm_storage_share" "eventExports" {
  name                 = "eventexports"
  storage_account_name = azurerm_storage_account.app.name
  quota                = 5
}