#output "id" {
#  value = azurerm_virtual_network.virtual_network.id
#}
#
#output "name" {
#  value = azurerm_virtual_network.virtual_network.name
#}

output "virtual_network_id" {
  value = azurerm_virtual_network.vnet.id
}

output "virtual_network_name" {
  value = azurerm_virtual_network.vnet.name
}

#output "subnets" {
#  value = azurerm_virtual_network.vnet.subnet
#  description = "The subnets within the virtual network"
#}

output "subnets" {
  value = {
    for subnet_key, subnet in azurerm_subnet.subnet : subnet_key => subnet.id
  }
}