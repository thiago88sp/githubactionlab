provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rsg" {
  name     = "rsg-tpontes-githubact"
  location = "East US"
}

resource "azurerm_service_plan" "app_plan" {
  name                = "tsp_app_plan"
  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_resource_group.rsg.location
  sku_name            = "F1"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "web_app" {
  name                = "tsp_web_app_0001010"
  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_service_plan.app_plan.location
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {}
}