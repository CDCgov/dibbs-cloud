data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_key_vault_secret" "db_username" {
  name         = "octopus-${var.env}-db-username"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "db_password" {
  name         = "octopus-${var.env}-db-password"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "octopus_admin_username" {
  name         = "octopus-${var.env}-admin-username"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "octopus_admin_password" {
  name         = "octopus-${var.env}-admin-password"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "octopus_master_key" {
  name         = "octopus-${var.env}-master-key"
  key_vault_id = var.key_vault_id
}