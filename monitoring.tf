resource "azurerm_application_insights" "app_insights" {
  name                = "appi-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  
  tags = var.tags
}

resource "azurerm_monitor_action_group" "critical_alerts" {
  name                = "ag-critical-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "critical"

  email_receiver {
    name                    = "admin"
    email_address           = var.admin_email
    use_common_alert_schema = true
  }
  
  tags = var.tags
}

# Alerta para disponibilidad de aplicaciones
resource "azurerm_monitor_metric_alert" "app_availability" {
  name                = "alert-availability-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_application_insights.app_insights.id]
  description         = "Alerta cuando la disponibilidad cae por debajo del 99%"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Insights/Components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 99
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical_alerts.id
  }
  
  tags = var.tags
}