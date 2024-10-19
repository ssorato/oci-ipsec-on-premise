resource "azurerm_resource_group" "azure_rg" {
  name     = format("rg-%s", var.common_sufix)
  location = var.azure_location

  tags = merge(
    {
      name = format("rg-%s", var.common_sufix)
    },
    var.common_tags
  )
}

resource "azurerm_virtual_network" "azure_vnet" {
  name                = format("vnet-%s", var.common_sufix)
  address_space       = ["${var.azure_vnet_cidr}"]
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.azure_rg.name
}

resource "azurerm_subnet" "azure_subnet" {
  name                 = format("subnet-%s", var.common_sufix)
  resource_group_name  = azurerm_resource_group.azure_rg.name
  virtual_network_name = azurerm_virtual_network.azure_vnet.name
  address_prefixes     = ["${var.azure_subnet_cidr}"]
}
