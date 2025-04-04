resource "azurerm_redis_cache" "redis" {
  name                = "redis-${var.project}-${var.environment}-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  capacity            = 0 # Cambiado de 1 a 0 (tamaño más pequeño)
  family              = "C"
  sku_name            = "Basic" # Cambiado de Standard a Basic
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  
  redis_configuration {
    maxmemory_policy = "allkeys-lru"
  }
  
  tags = var.tags
}

# Comentamos los private endpoints para simplificar la implementación
# y evitar problemas con cuentas gratuitas

# # Private Endpoint para Redis
# resource "azurerm_private_endpoint" "redis_private_endpoint" {
#   name                = "pe-redis-${var.project}-${var.environment}"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = var.location
#   subnet_id           = data.azurerm_subnet.subnet_redis.id

#   private_service_connection {
#     name                           = "psc-redis-${var.project}-${var.environment}"
#     private_connection_resource_id = azurerm_redis_cache.redis.id
#     subresource_names              = ["redisCache"]
#     is_manual_connection           = false
#   }

#   tags = var.tags
# }

# # DNS Zone para Redis
# resource "azurerm_private_dns_zone" "redis_dns_zone" {
#   name                = "privatelink.redis.cache.windows.net"
#   resource_group_name = azurerm_resource_group.rg.name
#   tags                = var.tags
# }

# # DNS A Record para Redis
# resource "azurerm_private_dns_a_record" "redis_dns_a_record" {
#   name                = azurerm_redis_cache.redis.name
#   zone_name           = azurerm_private_dns_zone.redis_dns_zone.name
#   resource_group_name = azurerm_resource_group.rg.name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.redis_private_endpoint.private_service_connection[0].private_ip_address]
# }

# # Virtual Network Link para Redis
# resource "azurerm_private_dns_zone_virtual_network_link" "redis_vnet_link" {
#   name                  = "vnetlink-redis-${var.project}-${var.environment}"
#   resource_group_name   = azurerm_resource_group.rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.redis_dns_zone.name
#   virtual_network_id    = data.azurerm_subnet.subnet_redis.virtual_network_id
#   tags                  = var.tags
# }