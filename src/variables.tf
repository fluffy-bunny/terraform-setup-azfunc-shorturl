variable "resource_group_name" {
  description = "(Required) The name of the resource group where resources will be created."
  type        = string
}

variable "location_name" {
  description = "(Required) The location where the resource group will reside."
  type        = string
}

variable "storage_account_name" {
  description = "(Required) The storage account name."
  type        = string
}

variable "plan_name" {
  description = "(Required) plan."
  type        = string
}
variable "app_insights_name" {
  description = "(Required) app_insights."
  type        = string
}
variable "func_name" {
  description = "(Required) func."
  type        = string
}

variable "keyvault_name" {
  description = "(Required) The main keyvault."
  type        = string
}

variable "cosmos_name" {
  description = "(Required) The main cosmos_name."
  type        = string
}

variable "cosmosConfigTemplateEmulator" {
  description = "(Required) The main cosmosConfigTemplateEmulator.  BASE64 encoded JSON "
  type        = string
}
variable "cosmosConfigTemplateProduction" {
  description = "(Required) The main cosmosConfigTemplateProduction.  BASE64 encoded JSON "
  type        = string
}


variable "cosmosPrimaryKeyEmulator" {
  description = "(Required) The main cosmosPrimaryKeyEmulator.  "
  type        = string
}
variable "azFuncShorturlClientCredentials" {
  description = "(Required) The main azFuncShorturlClientCredentials.  BASE64 encoded JSON "
  type        = string
}

variable "jwtValidateSettings" {
  description = "(Required) The main jwtValidateSettings.  BASE64 encoded JSON "
  type        = string
}

variable "event_hub_namespace" {
  description = "(Required) event_hub_namespace"
  type        = string
}
variable "event_hub_name" {
  description = "(Required) event_hub_name"
  type        = string
}


variable "tags" {
  description = "Tags to help identify various services."
  type        = map
  default = {
    Org            = "ssa"
    DeployedBy     = "terraform"
    Environment    = "prod"
    OwnerEmail     = "DL-P7-OPS@p7.com"
    Platform       = "na" # does not apply to us.
  }
}