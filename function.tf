resource "azurerm_linux_function_app" "function_app" {
  name                       = "func-${var.project}-${var.environment}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = data.azurerm_service_plan.function_service_plan.id
  storage_account_name       = data.azurerm_storage_account.storage_account.name
  storage_account_access_key = data.azurerm_storage_account.storage_account.primary_access_key
  
  site_config {
    application_stack {
      docker {
        registry_url = "https://${data.azurerm_container_registry.acr.login_server}"
        image_name   = "${var.project}/functions"
        image_tag    = "latest"
      }
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "dotnet"
    "SQL_CONNECTION_STRING" = "Server=tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.sql_db.name};User ID=${azurerm_mssql_server.sql_server.administrator_login};Password=${var.sql_password};Encrypt=true;"
    "STORAGE_CONNECTION_STRING" = data.azurerm_storage_account.storage_account.primary_connection_string
    "REDIS_CONNECTION_STRING" = azurerm_redis_cache.redis.primary_connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app_insights.instrumentation_key
    "ORDER_QUEUE_NAME" = "order-processing"
    "INVENTORY_QUEUE_NAME" = "inventory-updates"
    "EMAIL_QUEUE_NAME" = "email-notifications"
    "DOCKER_REGISTRY_SERVER_URL" = "https://${data.azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = data.azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = data.azurerm_container_registry.acr.admin_password
  }

  identity {
    type = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.app_service_identity.id]
  }

  tags = var.tags
}

# Integración de VNET para Function App
resource "azurerm_app_service_virtual_network_swift_connection" "function_vnet" {
  app_service_id = azurerm_linux_function_app.function_app.id
  subnet_id      = data.azurerm_subnet.subnet_function.id
}

# Comentamos los private endpoints para simplificar la implementación
# y evitar problemas con cuentas gratuitas

# # Private Endpoint para Function App
# resource "azurerm_private_endpoint" "function_private_endpoint" {
#   name                = "pe-func-${var.project}-${var.environment}"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = var.location
#   subnet_id           = data.azurerm_subnet.subnet_function.id

#   private_service_connection {
#     name                           = "psc-func-${var.project}-${var.environment}"
#     private_connection_resource_id = azurerm_linux_function_app.function_app.id
#     subresource_names              = ["sites"]
#     is_manual_connection           = false
#   }

#   tags = var.tags
# }

# # DNS Zone para Function App
# resource "azurerm_private_dns_zone" "function_dns_zone" {
#   name                = "privatelink.azurewebsites.net"
#   resource_group_name = azurerm_resource_group.rg.name
#   tags                = var.tags
# }

# # DNS A Record para Function App
# resource "azurerm_private_dns_a_record" "function_dns_a_record" {
#   name                = azurerm_linux_function_app.function_app.name
#   zone_name           = azurerm_private_dns_zone.function_dns_zone.name
#   resource_group_name = azurerm_resource_group.rg.name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.function_private_endpoint.private_service_connection[0].private_ip_address]
# }