resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  address_space       = var.virtual_network_address_space
  location            = var.virtual_network_location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        actions = delegation.value.service_delegation.actions
        name    = delegation.value.service_delegation.name
      }
    }
  }

  service_endpoints = each.value.service_endpoints
}


resource "azurerm_virtual_network_peering" "vnet_peering" {
  for_each = var.peerings

  name                      = each.value.name
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = each.value.remote_virtual_network_id

  allow_forwarded_traffic = each.value.allow_forwarded_traffic
  allow_gateway_transit   = each.value.allow_gateway_transit
  use_remote_gateways     = each.value.use_remote_gateways
}