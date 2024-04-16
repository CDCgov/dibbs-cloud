output "subnet_lbs_id" {
  value = azurerm_subnet.lbs.id
}

output "subnet_appgw_id" {
  value = azurerm_subnet.appgw.id
}

output "subnet_kube_id" {
  value = azurerm_subnet.kube.id
}

output "network" {
  value = azurerm_virtual_network.vnet
}

output "agic_id" {
  value = azurerm_application_gateway.k8s.id
}