/*
    NOTE: Azure API Management can take upwards of 30 minutes or more to provision.

    Provisioning time is shortened by the use of a "Consumption" SKU, since it is run on
    shared infrastructure that is already in place. If dedicated infrastructure is required
    under the terms of jurisdictional regulations or statutes, use a "Developer" SKU or higher.
    If the deployment process times out, the APIM resources must be manually imported into the
    terraform state file.

*/
resource "azurerm_api_management" "apim" {
  count = var.activate_apim ? 1 : 0
  name                = "${local.name}-apim"
  resource_group_name = var.resource_group_name
  location            = var.location
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.apim_sku_name

  identity {
    type = "SystemAssigned"
  }

}
resource "azurerm_api_management_custom_domain" "apim_domain" {
  count             = var.requires_custom_host_name_configuration ? 1 && var.activate_apim : 0
  api_management_id = azurerm_api_management.this.id

  dynamic "developer_portal" {
    for_each = var.developer_portal_host_name != "" ? [1] : []
    content {
      host_name                    = var.developer_portal_host_name
      key_vault_id                 = azurerm_key_vault_certificate.example.secret_id
      negotiate_client_certificate = false

    }
  }

  dynamic "management" {
    for_each = var.management_host_name != "" ? [1] : []
    content {
      host_name                    = var.management_host_name
      key_vault_id                 = azurerm_key_vault_certificate.example.secret_id
      negotiate_client_certificate = false

    }
  }

  dynamic "gateway" {
    for_each = var.gateway_host_name != "" ? [1] : []
    content {
      host_name                    = var.gateway_host_name
      key_vault_id                 = azurerm_key_vault_certificate.example.secret_id
      negotiate_client_certificate = true

    }
  }

  depends_on = [azurerm_api_management.apim, azurerm_application_gateway.load_balancer, azurerm_key_vault_certificate.example]
}