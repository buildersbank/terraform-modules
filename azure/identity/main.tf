resource "azurerm_user_assigned_identity" "_" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
}