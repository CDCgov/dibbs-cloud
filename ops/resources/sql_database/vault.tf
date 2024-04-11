resource "azurerm_key_vault_secret" "db_username" {
  key_vault_id = var.global_vault_id
  name         = "octopus-${var.env}-db-username"
  value        = var.administrator_login
}

data "azurerm_key_vault_secret" "db_password" {
  name         = "octopus-${var.env}-db-password"
  key_vault_id = var.global_vault_id
}