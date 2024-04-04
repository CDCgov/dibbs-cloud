output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "resource_group_location" {
  value = data.azurerm_resource_group.rg.location
}

output "resource_group_id" {
  value = data.azurerm_resource_group.rg.id
}

output "acr_name" {
  value = data.azurerm_container_registry.acr.name
}

#output "acr_admin_username" {
#  value = azurerm_container_registry.acr.admin_username
#}

#output "acr_admin_password" {
#  value     = azurerm_container_registry.acr.admin_password
#  sensitive = true
#}