variable "project" {
  description = "Nombre del proyecto"
  type        = string
  default     = "ecommerce"
}

variable "environment" {
  description = "Entorno de despliegue (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Región de Azure para los recursos"
  type        = string
  default     = "East US 2"
}

variable "tags" {
  description = "Etiquetas para los recursos"
  type        = map(string)
  default     = {
    environment = "dev"
    project     = "ecommerce"
    created_by  = "terraform"
    repository  = "repo-c-apps"
  }
}

variable "domain_name" {
  description = "Nombre de dominio principal"
  type        = string
  default     = "mitiendaonline.com"
}

variable "sql_password" {
  description = "Contraseña para el administrador de SQL Server"
  type        = string
  sensitive   = true
}

variable "admin_ip_range" {
  description = "Rango de IPs permitidas para acceso administrativo"
  type        = string
  default     = "0.0.0.0/0"  # Cambiar a un rango específico en producción
}

variable "admin_email" {
  description = "Email para notificaciones de alertas"
  type        = string
  default     = "admin@mitiendaonline.com"
}

variable "infra_resource_group_name" {
  description = "Nombre del grupo de recursos de infraestructura"
  type        = string
  default     = "rg-ecommerce-infra-dev"
}

variable "storage_resource_group_name" {
  description = "Nombre del grupo de recursos de almacenamiento"
  type        = string
  default     = "rg-ecommerce-storage-dev"
}