data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_key_vault_secret" "service_principal_client_id" {
  name         = "${var.env}-service-principal-client-id"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "service_principal_client_secret" {
  name         = "${var.env}-service-principal-client-secret"
  key_vault_id = var.key_vault_id
}