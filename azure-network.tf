resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.environment}-${var.vnet_name}"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

