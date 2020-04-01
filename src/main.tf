terraform {
  backend "azurerm" {
    # Due to a limitation in backend objects, variables cannot be passed in.
    # Do not declare an access_key here. Instead, export the
    # ARM_ACCESS_KEY environment variable.

    storage_account_name  = "stterraformgithubactions"
    container_name        = "tstate"
    key                   = "terraform.tfstate"
  }
}
# Configure the Azure provider
provider "azurerm" {
  version = "=1.44.0"
}
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location_name
}

data "azurerm_subscription" "primary" {}
data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "main" {
  name                = var.plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}
resource "azurerm_application_insights" "main" {
  name                = var.app_insights_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}
resource "azurerm_function_app" "main" {
  name                      = var.func_name
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  app_service_plan_id       = azurerm_app_service_plan.main.id
  storage_connection_string = azurerm_storage_account.main.primary_connection_string
  identity { type = "SystemAssigned" }
  app_settings = {
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE"                   = "true",
    "WEBSITE_RUN_FROM_PACKAGE"                          = "1",
    "APPINSIGHTS_INSTRUMENTATIONKEY"                    = azurerm_application_insights.main.instrumentation_key,
    "APPLICATIONINSIGHTS_CONNECTION_STRING"             = format("InstrumentationKey=%s", azurerm_application_insights.main.instrumentation_key),
    "FUNCTIONS_WORKER_RUNTIME"                          = "dotnet"
  }
  version="~3"

}

