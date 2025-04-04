resource "azurerm_redis_cache" "redis" {
  name                = "redis-${var.project}-${var.environment}-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  capacity            = 0 # Cambiado de 1 a 0 (tamaño más pequeño)
  family              = "C"
  sku_name            = "Basic" # Cambiado de Standard a Basic
  minimum_tls_version = "1.2"
  
  redis_configuration {
    maxmemory_policy = "allkeys-lru"
  }
  
  tags = var.tags
}

