output "subnet_lbs_id" {
  value = azurerm_subnet.lbs.id
}

output "network" {
  value = azurerm_virtual_network.vnet
}
