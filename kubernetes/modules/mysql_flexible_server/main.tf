resource "azurerm_mysql_flexible_server" "mysql" {
  name                = var.mysql_server_name
  location            = var.location
  resource_group_name = var.resource_group_name
  administrator_login = var.mysql_server_admin_login
  administrator_password = var.mysql_server_admin_password
  version             = var.mysql_version
  sku_name            = var.sku_name

  storage {
    auto_grow_enabled  = var.storage.auto_grow_enabled
    size_gb            = var.storage.size_gb
    io_scaling_enabled = var.storage.io_scaling_enabled
    iops               = var.storage.iops
  }

  backup_retention_days = var.backup_retention_days
  #geo_redundant_backup = var.geo_redundant_backup
  #availability_zone   = var.availability_zone
  # delegated_subnet_id = var.delegated_subnet_id
  #private_dns_zone_id = var.private_dns_zone_id

  tags = var.tags
}
# Resource to create a MySQL database in the MySQL flexible server
resource "azurerm_mysql_flexible_database" "database" {
  name                = var.mysql_database_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  resource_group_name = azurerm_mysql_flexible_server.mysql.resource_group_name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}


