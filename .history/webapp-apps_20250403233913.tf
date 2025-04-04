# App Service para UI Pública
resource "azurerm_linux_web_app" "webapp_public" {
  name                = "app-public-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = data.azurerm_service_plan.app_service_plan.id
  
  site_config {
    always_on = true
    application_stack {
      docker_image     = "${data.azurerm_container_registry.acr.login_server}/${var.project}/public-ui"
      docker_image_tag = "latest"
    }
    vnet_route_all_enabled = true
    cors {
      allowed_origins = ["https://static.${var.domain_name}", "https://*.${var.domain_name}"]
    }
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL" = "https://${data.azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = data.azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = data.azurerm_container_registry.acr.admin_password
    "WEBSITE_VNET_ROUTE_ALL" = "1"
    "API_URL" = "https://api-${var.project}-${var.environment}.azurewebsites.net"
    "REDIS_CONNECTION_STRING" = azurerm_redis_cache.redis.primary_connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app_insights.instrumentation_key
  }

  identity {
    type = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.app_service_identity.id]
  }

  tags = var.tags
}

# Integración de VNET para UI Pública
resource "azurerm_app_service_virtual_network_swift_connection" "webapp_public_vnet" {
  app_service_id = azurerm_linux_web_app.webapp_public.id
  subnet_id      = data.azurerm_subnet.subnet_web.id
}

# App Service para UI Administrativa
resource "azurerm_linux_web_app" "webapp_admin" {
  name                = "app-admin-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = data.azurerm_service_plan.app_service_plan.id
  
  site_config {
    always_on = true
    application_stack {
      docker_image     = "${data.azurerm_container_registry.acr.login_server}/${var.project}/admin-ui"
      docker_image_tag = "latest"
    }
    vnet_route_all_enabled = true
    ip_restriction {
      action = "Allow"
      ip_address = var.admin_ip_range
      name = "allow-admin-ips"
      priority = 100
    }
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL" = "https://${data.azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = data.azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = data.azurerm_container_registry.acr.admin_password
    "WEBSITE_VNET_ROUTE_ALL" = "1"
    "API_URL" = "https://api-${var.project}-${var.environment}.azurewebsites.net"
    "REDIS_CONNECTION_STRING" = azurerm_redis_cache.redis.primary_connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app_insights.instrumentation_key
  }

  identity {
    type = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.app_service_identity.id]
  }

  tags = var.tags
}

# Integración de VNET para UI Administrativa
resource "azurerm_app_service_virtual_network_swift_connection" "webapp_admin_vnet" {
  app_service_id = azurerm_linux_web_app.webapp_admin.id
  subnet_id      = data.azurerm_subnet.subnet_web.id
}

# App Service para API
resource "azurerm_linux_web_app" "api" {
  name                = "api-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = data.azurerm_service_plan.app_service_plan.id
  
  site_config {
    always_on = true
    application_stack {
      docker_image     = "${data.azurerm_container_registry.acr.login_server}/${var.project}/api"
      docker_image_tag = "latest"
    }
    vnet_route_all_enabled = true
    cors {
      allowed_origins = ["https://app-public-${var.project}-${var.environment}.azurewebsites.net", "https://app-admin-${var.project}-${var.environment}.azurewebsites.net"]
    }
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL" = "https://${data.azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = data.azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = data.azurerm_container_registry.acr.admin_password
    "WEBSITE_VNET_ROUTE_ALL" = "1"
    "SQL_CONNECTION_STRING" = "Server=tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.sql_db.name};User ID=${azurerm_mssql_server.sql_server.administrator_login};Password=${var.sql_password};Encrypt=true;"
    "STORAGE_CONNECTION_STRING" = data.azurerm_storage_account.storage_account.primary_connection_string
    "REDIS_CONNECTION_STRING" = azurerm_redis_cache.redis.primary_connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app_insights.instrumentation_key
    "ORDER_QUEUE_NAME" = "order-processing"
    "INVENTORY_QUEUE_NAME" = "inventory-updates"
    "EMAIL_QUEUE_NAME" = "email-notifications"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.app_service_identity.id]
  }

  tags = var.tags
}

# Integración de VNET para API
resource "azurerm_app_service_virtual_network_swift_connection" "api_vnet" {
  app_service_id = azurerm_linux_web_app.api.id
  subnet_id      = data.azurerm_subnet.subnet_api.id
}