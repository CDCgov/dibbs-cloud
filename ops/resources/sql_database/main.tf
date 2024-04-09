resource "azurerm_mssql_server" "octopus" {
  name                         = "dibbs-ce-${var.env}-octopus-sqlserver"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = azurerm_key_vault_secret.db_username.value
  administrator_login_password = data.azurerm_key_vault_secret.db_password.value

  //public_network_access_enabled = false
}

resource "azurerm_mssql_database" "octopus" {
  name           = "octopus-db"
  server_id      = azurerm_mssql_server.octopus.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 5
  sku_name       = "S0"
  enclave_type   = "VBS"

  tags = {
    foo = "bar"
  }

  # prevent the possibility of accidental data loss
  /*lifecycle {
    prevent_destroy = true
  }*/
}

resource "azurerm_mssql_firewall_rule" "example" {
  name             = "AzureServices"
  server_id        = azurerm_mssql_server.octopus.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_virtual_network_rule" "octopus" {
  name      = "sql-vnet-rule"
  server_id = azurerm_mssql_server.octopus.id
  subnet_id = var.webapp_subnet_id
}