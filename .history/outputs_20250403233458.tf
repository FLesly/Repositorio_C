output "public_webapp_url" {
  value       = "https://${azurerm_linux_web_app.webapp_public.default_hostname}"
  description = "URL de la aplicación web pública"
}

output "admin_webapp_url" {
  value       = "https://${azurerm_linux_web_app.webapp_admin.default_hostname}"
  description = "URL de la aplicación web administrativa"
}

output "api_url" {
  value       = "https://${azurerm_linux_web_app.api.default_hostname}"
  description = "URL de la API"
}

output "function_app_url" {
  value       = "https://${azurerm_linux_function_app.function_app.default_hostname}"
  description = "URL de la Function App"
}

output "sql_server_fqdn" {
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
  description = "FQDN del servidor SQL"
}

output "redis_hostname" {
  value       = azurerm_redis_cache.redis.hostname
  description = "Hostname de Redis Cache"
}

output "app_insights_instrumentation_key" {
  value       = azurerm_application_insights.app_insights.instrumentation_key
  description = "Clave de instrumentación de Application Insights"
  sensitive   = true
}

output "app_insights_app_id" {
  value       = azurerm_application_insights.app_insights.app_id
  description = "ID de la aplicación en Application Insights"
}