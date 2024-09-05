variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "virtual_network_address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
}

variable "virtual_network_location" {
  description = "The location of the virtual network"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "subnets" {
  description = "A map of subnets to create"
  type = map(object({
    address_prefixes = list(string)
    service_endpoints = list(string)
    delegation = object({
      name = string
      service_delegation = object({
        actions = list(string)
        name    = string
      })
    })
  }))
}

variable "peerings" {
  description = "A map of virtual network peerings to create"
  type = map(object({
    name                      = string
    remote_virtual_network_id = string
    allow_forwarded_traffic   = bool
    allow_gateway_transit     = bool
    use_remote_gateways       = bool
  }))
  default = {}
}
