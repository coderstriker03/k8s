locals {
  diag_resource_list = var.diagnostics != null ? split("/", var.diagnostics.destination) : []
  parsed_diag = var.diagnostics != null ? {
    log_analytics_id   = contains(local.diag_resource_list, "Microsoft.OperationalInsights") ? var.diagnostics.destination : null
    storage_account_id = contains(local.diag_resource_list, "Microsoft.Storage") ? var.diagnostics.destination : null
    event_hub_auth_id  = contains(local.diag_resource_list, "Microsoft.EventHub") ? var.diagnostics.destination : null
    metric             = var.diagnostics.metrics
    log                = var.diagnostics.logs
    } : {
    log_analytics_id   = null
    storage_account_id = null
    event_hub_auth_id  = null
    metric             = []
    log                = []
  }
}

#resource "azurerm_resource_group" "this" {
#  name     = var.resource_group_name
#  location = var.location
#  tags     = var.tags
#}

resource "azurerm_cosmosdb_account" "this" {
  name                              = var.name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  offer_type                        = "Standard"
  kind                              = "MongoDB"
  #enable_automatic_failover         = var.enable_automatic_failover
  ip_range_filter                   = join(",", var.ip_range_filter)
  is_virtual_network_filter_enabled = true
  tags                              = var.tags
  mongo_server_version              = var.mongo_server_version
  analytical_storage_enabled        = true

  capabilities {
    name = "EnableMongo"
  }

  dynamic "capabilities" {
    for_each = var.capabilities != null ? var.capabilities : []
    content {
      name = capabilities.value
    }
  }

  consistency_policy {
    consistency_level = "Session"
    #max_interval_in_seconds = 5
    #max_staleness_prefix    = 100
  }

  geo_location {
    #location          = var.virtual_network_location
    location          = var.location
    failover_priority = 0
  }

  dynamic "geo_location" {
    for_each = var.additional_geo_locations
    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      #zone_redundant    = geo_location.value.zone_redundant
    }
  }

  dynamic "virtual_network_rule" {
    for_each = var.virtual_network_rules

    content {
      id                                   = virtual_network_rule.value
      ignore_missing_vnet_service_endpoint = false
    }
  }
}

resource "azurerm_cosmosdb_mongo_database" "this" {
  for_each            = var.mongo_dbs
  name                = each.value.db_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
}
