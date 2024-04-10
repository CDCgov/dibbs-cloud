locals {
  name = "${var.team}-${var.project}-${var.env}"
}

resource "azurerm_mssql_server" "sql" {
  name                         = "${local.name}-sqlserver"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = azurerm_key_vault_secret.db_username.value
  administrator_login_password = data.azurerm_key_vault_secret.db_password.value

  minimum_tls_version = "1.2"

  // Uncomment this if you wish to use a Private Endpoint setup instead of VNET rules.
  //public_network_access_enabled = false
}

resource "azurerm_mssql_database" "sql_database" {
  name         = "${local.name}-db"
  server_id    = azurerm_mssql_server.sql.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 5
  sku_name     = "S0"
  enclave_type = "VBS"

  tags = {
    foo = "bar"
  }

  # prevent the possibility of accidental data loss
  /*lifecycle {
    prevent_destroy = true
  }*/
}

resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AzureServices"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_virtual_network_rule" "sql_vnet_rule" {
  name      = "sql-vnet-rule"
  server_id = azurerm_mssql_server.sql.id
  subnet_id = var.webapp_subnet_id
}

resource "azurerm_mssql_database_extended_auditing_policy" "octopus" {
  database_id                             = azurerm_mssql_database.sql_database.id
  storage_endpoint                        = var.primary_blob_endpoint
  storage_account_access_key              = var.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 30
}