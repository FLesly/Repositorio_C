provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project}-apps-${var.environment}"
  location = var.location
  tags     = var.tags
}

# Generar un sufijo aleatorio para nombres únicos
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Datos de recursos existentes
data "azurerm_service_plan" "app_service_plan" {
  name                = "asp-${var.project}-${var.environment}"
  resource_group_name = var.infra_resource_group_name
}

data "azurerm_service_plan" "function_service_plan" {
  name                = "asp-func-${var.project}-${var.environment}"
  resource_group_name = var.infra_resource_group_name
}

data "azurerm_user_assigned_identity" "app_service_identity" {
  name                = "id-asp-${var.project}-${var.environment}"
  resource_group_name = var.infra_resource_group_name
}

data "azurerm_container_registry" "acr" {
  name                = "acr${var.project}${var.environment}*" # Usar comodín para buscar el ACR con sufijo aleatorio
  resource_group_name = var.infra_resource_group_name
}

data "azurerm_storage_account" "storage_account" {
  name                = "st${var.project}${var.environment}*" # Usar comodín para buscar la cuenta de almacenamiento con sufijo aleatorio
  resource_group_name = var.storage_resource_group_name
}

data "azurerm_subnet" "subnet_web" {
  name                 = "subnet-web-${var.project}-${var.environment}"
  virtual_network_name = "vnet-${var.project}-${var.environment}"
  resource_group_name  = var.infra_resource_group_name
}

data "azurerm_subnet" "subnet_api" {
  name                 = "subnet-api-${var.project}-${var.environment}"
  virtual_network_name = "vnet-${var.project}-${var.environment}"
  resource_group_name  = var.infra_resource_group_name
}

data "azurerm_subnet" "subnet_function" {
  name                 = "subnet-function-${var.project}-${var.environment}"
  virtual_network_name = "vnet-${var.project}-${var.environment}"
  resource_group_name  = var.infra_resource_group_name
}

data "azurerm_subnet" "subnet_db" {
  name                 = "subnet-db-${var.project}-${var.environment}"
  virtual_network_name = "vnet-${var.project}-${var.environment}"
  resource_group_name  = var.infra_resource_group_name
}

data "azurerm_subnet" "subnet_redis" {
  name                 = "subnet-redis-${var.project}-${var.environment}"
  virtual_network_name = "vnet-${var.project}-${var.environment}"
  resource_group_name  = var.infra_resource_group_name
}