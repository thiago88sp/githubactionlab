provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    storage_account_name = "tspontes7xg2dfzesta001"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
  }
}

resource "azurerm_resource_group" "rsg" {
  name     = "tpontes-lacework"
  location = "East US"

  tags = {
    Username = "tpontes"
    Source   = "Terraform"
    Purpose = "Lacework Test"
  }
}

resource "azurerm_service_plan" "app_plan" {
  name                = "tsp_app_plan-001"
  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_resource_group.rsg.location
  sku_name            = "B1"
  os_type             = "Windows"

  tags = {
    Username = "tpontes"
    Source   = "Terraform"
  }
}

resource "azurerm_windows_web_app" "web_app" {
  name                = "tsp-web-app-0001"
  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_service_plan.app_plan.location
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {}

  tags = {
    Username = "tpontes"
    Source   = "Terraform"
  }
}
