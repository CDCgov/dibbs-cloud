provider "azurerm" {
  features {}

  #TODO: Ask the team if we should mask these in vault for the templates or just as a github variable.
  # Vault may add an additional level of security
  subscription_id   = "<azure_subscription_id>"
  tenant_id         = "<azure_subscription_tenant_id>"
  client_id         = "<service_principal_appid>"
  client_secret     = "<service_principal_password>"
}