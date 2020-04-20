terraform {
  backend "azurerm" {
    # Due to a limitation in backend objects, variables cannot be passed in.
    # Do not declare an access_key here. Instead, export the
    # ARM_ACCESS_KEY environment variable.

    storage_account_name  = "stterraformshorturl2"
    container_name        = "tstate"
    key                   = "terraform.tfstate"
  }
}
# Configure the Azure provider
provider "azurerm" {
 version = "=2.0.0" 
 features {
   
  }
}
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location_name
  tags = var.tags
}

data "azurerm_client_config" "current" {}
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
  tags = var.tags
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
  tags = var.tags
}
resource "azurerm_application_insights" "main" {
  name                = var.app_insights_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  tags = var.tags
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
  tags = var.tags

}

resource "azurerm_key_vault_access_policy" "appAccess" {

  key_vault_id                = azurerm_key_vault.main.id
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  object_id                   = azurerm_function_app.main.identity.0.principal_id

  key_permissions = [
      "create",  "get",   "list", "sign", "verify" 
    ]

    secret_permissions = [
       "get", "list" 
    ]

    certificate_permissions = [
    "get",
    "getissuers",
    "list",
    "listissuers" 
  ]

}


resource "azurerm_key_vault_access_policy" "fullaccess" {

  key_vault_id                = azurerm_key_vault.main.id
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  object_id                   = data.azurerm_client_config.current.object_id

  key_permissions = [
      "backup", "create", "decrypt", "delete", "encrypt", "get", "import", "list", "purge", "recover", "restore", "sign", "unwrapKey", "update", "verify","wrapKey"
    ]


    secret_permissions = [
      "backup","delete","get", "list","purge","recover","restore","set"
    ]

    storage_permissions = [
      "backup","delete", "deletesas", "get", "getsas", "list", "listsas", "purge", "recover", "regeneratekey", "restore", "set", "setsas","update"
    ]

    certificate_permissions = [
    "backup",
    "create",
    "delete",
    "deleteissuers",
    "get",
    "getissuers",
    "import",
    "list",
    "listissuers",
    "managecontacts",
    "manageissuers",
    "purge",
    "recover",
    "restore",
    "setissuers",
    "update",
  ]

}

resource "azurerm_key_vault" "main" {
  name                        = var.keyvault_name
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
  purge_protection_enabled    = false

  sku_name = "standard"
  tags = var.tags

   
}

resource "azurerm_cosmosdb_account" "db" {
  name                      = var.cosmos_name
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    prefix            = "shorturl2-customid"
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
  tags = var.tags
}
resource "azurerm_cosmosdb_sql_database" "sql_database" {
  name                = "db-shortUrl"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = var.cosmos_name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "container_operational" {
  name                = "operational"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = var.cosmos_name
  database_name       = azurerm_cosmosdb_sql_database.sql_database.name
  partition_key_path  = "/id"
  throughput          = 400

  default_ttl         = -1

}
resource "azurerm_key_vault_secret" "cosmosPrimaryKeyProduction" {
  name         = "cosmosPrimaryKeyProduction"
  value        = azurerm_cosmosdb_account.db.primary_master_key
  key_vault_id = azurerm_key_vault.main.id

  tags = {
    environment = "Production"
  }
} 

resource "azurerm_key_vault_secret" "cosmosPrimaryKeyEmulator" {
  name         = "cosmosPrimaryKeyEmulator"
  value        = var.cosmosPrimaryKeyEmulator
  key_vault_id = azurerm_key_vault.main.id

  tags = {
    environment = "Production"
  }
} 

resource "azurerm_key_vault_secret" "cosmosConfigTemplateEmulator" {
  name         = "cosmosConfigTemplateEmulator"
  value        = var.cosmosConfigTemplateEmulator
  key_vault_id = azurerm_key_vault.main.id

  tags = {
    environment = "Dev"
  }
} 

resource "azurerm_key_vault_secret" "cosmosConfigTemplateProduction" {
  name         = "cosmosConfigTemplateProduction"
  value        = var.cosmosConfigTemplateProduction
  key_vault_id = azurerm_key_vault.main.id

  tags = {
    environment = "Production"
  }
} 

resource "azurerm_key_vault_secret" "azFuncShorturlClientCredentials" {
  name         = "azFuncShorturlClientCredentials"
  value        = var.azFuncShorturlClientCredentials
  key_vault_id = azurerm_key_vault.main.id

  tags = {
    environment = "Production"
  }
} 

resource "azurerm_key_vault_secret" "jwtValidateSettings" {
  name         = "jwtValidateSettings"
  value        = var.jwtValidateSettings
  key_vault_id = azurerm_key_vault.main.id

  tags = {
    environment = "Production"
  }
} 


