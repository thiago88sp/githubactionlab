provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    storage_account_name = "statpontesshared"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
  }
}

resource "azurerm_resource_group" "rsg" {
  name     = "rsg-tpontes-lacework"
  location = "East US"

  tags = {
    Username = "tpontes"
    Source   = "Terraform"
    Purpose = "Lacework Test"
  }
}

#resource "azurerm_service_plan" "app_plan" {
#  name                = "tsp_lw_app_plan-010"
#  resource_group_name = azurerm_resource_group.rsg.name
#  location            = azurerm_resource_group.rsg.location
#  sku_name            = "B1"
#  os_type             = "Windows"
#
#  tags = {
#    Username = "tpontes"
#    Source   = "Terraform"
#  }
#}
#
#resource "azurerm_windows_web_app" "web_app" {
#  name                = "tsp-lw-web-app-0010"
#  resource_group_name = azurerm_resource_group.rsg.name
#  location            = azurerm_service_plan.app_plan.location
#  service_plan_id     = azurerm_service_plan.app_plan.id
#
#  site_config {}
#
#  https_only = true
#
#  tags = {
#    Username = "tpontes"
#    Source   = "Terraform"
#  }
#}
