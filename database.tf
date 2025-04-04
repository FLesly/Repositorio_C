resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-${var.project}-${var.environment}-${random_string.suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.sql_password
  minimum_tls_version          = "1.2"
  
  tags = var.tags
}

resource "azurerm_mssql_database" "sql_db" {
  name      = "${var.project}_db"
  server_id = azurerm_mssql_server.sql_server.id
  sku_name  = "Basic" # Cambiado de S1 a Basic para reducir costos
  
  tags = var.tags
}

# Comentamos los private endpoints para simplificar la implementación
# y evitar problemas con cuentas gratuitas

# # Private Endpoint para SQL Server
# resource "azurerm_private_endpoint" "sql_private_endpoint" {
#   name                = "pe-sql-${var.project}-${var.environment}"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = var.location
#   subnet_id           = data.azurerm_subnet.subnet_db.id

#   private_service_connection {
#     name                           = "psc-sql-${var.project}-${var.environment}"
#     private_connection_resource_id = azurerm_mssql_server.sql_server.id
#     subresource_names              = ["sqlServer"]
#     is_manual_connection           = false
#   }

#   tags = var.tags
# }

# # DNS Zone para SQL Server
# resource "azurerm_private_dns_zone" "sql_dns_zone" {
#   name                = "privatelink.database.windows.net"
#   resource_group_name = azurerm_resource_group.rg.name
#   tags                = var.tags
# }

# # DNS A Record para SQL Server
# resource "azurerm_private_dns_a_record" "sql_dns_a_record" {
#   name                = azurerm_mssql_server.sql_server.name
#   zone_name           = azurerm_private_dns_zone.sql_dns_zone.name
#   resource_group_name = azurerm_resource_group.rg.name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.sql_private_endpoint.private_service_connection[0].private_ip_address]
# }

# # Virtual Network Link para SQL Server
# resource "azurerm_private_dns_zone_virtual_network_link" "sql_vnet_link" {
#   name                  = "vnetlink-sql-${var.project}-${var.environment}"
#   resource_group_name   = azurerm_resource_group.rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.sql_dns_zone.name
#   virtual_network_id    = data.azurerm_subnet.subnet_db.virtual_network_id
#   tags                  = var.tags
# }