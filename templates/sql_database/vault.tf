resource "azurerm_key_vault_secret" "db_username" {
  key_vault_id = var.vault_id
  name         = "${var.env}-db-username"
  value        = var.administrator_login
}

//NOTE: This will need to be manually created in your key vault before running terraform.
data "azurerm_key_vault_secret" "db_password" {
  name         = "${var.env}-db-password"
  key_vault_id = var.vault_id
}