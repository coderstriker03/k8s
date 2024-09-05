
resource "azurerm_eventhub_namespace" "this" {
  name                = var.namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name
   sku                 = "Standard"
   capacity = 1
  
  zone_redundant       = var.zone_redundant
  auto_inflate_enabled = var.auto_inflate_enabled
  maximum_throughput_units = var.maximum_throughput_units
  tags                 = var.tags
}

resource "azurerm_eventhub" "this" {
  for_each           = { for hub in var.eventhubs : hub.name => hub }
  name               = each.value.name
  namespace_name     = azurerm_eventhub_namespace.this.name
  resource_group_name               = var.resource_group_name
  partition_count    = each.value.partition_count
  message_retention  = each.value.message_retention
}

resource "azurerm_eventhub_namespace_authorization_rule" "this" {
  for_each           = { for rule in var.authorization_rules : rule.name => rule }
  name               = each.key
  namespace_name     = azurerm_eventhub_namespace.this.name
  resource_group_name               = var.resource_group_name
  listen             = each.value.listen
  manage             = lookup(each.value, "manage", false)
  send               = each.value.send
  #eventhub_name      = lookup(each.value, "eventhub_name", null)
}

#resource "azurerm_eventhub_consumer_group" "this" {
#  for_each 			 = { for group in var.consumer_groups : "${group.name}-${group.eventhub_name}" => group }
#  name               = each.value.name
#  namespace_name     = azurerm_eventhub_namespace.this.name
#  eventhub_name      = each.value.eventhub_name
#  resource_group_name = azurerm_resource_group.this.name
#}

variable "namespace_name" {
  description = "The name of the Event Hub namespace."
  type        = string
}

variable "location" {
  description = "The location where the resources will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "zone_redundant" {
  description = "Indicates if zone redundancy is enabled."
  type        = bool
}


variable "auto_inflate_enabled" {
  description = "Indicates if auto-inflate is enabled."
  type        = bool
}

variable "maximum_throughput_units" {
  description = "The maximum throughput units for the namespace."
  type        = number
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "private_endpoint_connections" {
  description = "A list of private endpoint connections."
  type = list(object({
    name                 = string
    private_endpoint_id  = string
    connection_state = object({
      status        = string
      description   = string
      actions_required = string
    })
    group_ids           = list(string)
  }))
  default = []
}

variable "eventhubs" {
  description = "List of event hubs to create."
  type = list(object({
    name               = string
    partition_count    = number
    message_retention  = number
  }))
}

variable "authorization_rules" {
  description = "List of authorization rules to create."
  type = list(object({
    name              = string
    listen            = bool
    manage            = bool
    send              = bool
    eventhub_name     = string
  }))
}

#variable "consumer_groups" {
#  description = "List of consumer groups to create."
#  type = list(object({
#    name            = string
#    eventhub_name   = string
#  }))
#}
