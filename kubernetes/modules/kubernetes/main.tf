resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  node_resource_group = var.node_resource_group
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                  = var.default_node_pool_name
    node_count            = var.default_node_count
    vm_size               = var.default_vm_size
    os_disk_size_gb       = var.default_os_disk_size_gb
    os_disk_type          = var.default_os_disk_type
    kubelet_disk_type     = var.default_kubelet_disk_type
    max_pods              = var.default_max_pods
    type                  = var.default_node_type
    enable_auto_scaling   = var.default_enable_auto_scaling
    scale_down_mode       = var.default_scale_down_mode
    orchestrator_version  = var.default_orchestrator_version
    enable_node_public_ip = var.default_enable_node_public_ip
    #mode                  = var.default_mode
    #os_type               = var.default_os_type
    os_sku                = var.default_os_sku
    vnet_subnet_id        = var.vnet_subnet_id
  }


  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    load_balancer_sku  = var.load_balancer_sku
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    #docker_bridge_cidr = var.docker_bridge_cidr
    outbound_type      = var.outbound_type
  }

  
  #rbac {
  #  enabled = true
  #}

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "additional_pools" {
  for_each = var.additional_node_pools

  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  name                  = each.value.node_name
  node_count            = each.value.node_count
  vm_size               = each.value.vm_size
  #availability_zones    = each.value.zones
  max_pods              = 250
  os_disk_size_gb       = 128
  os_type               = each.value.node_os
  vnet_subnet_id        = var.vnet_subnet_id
  node_taints           = each.value.taints
  enable_auto_scaling   = each.value.cluster_auto_scaling
  min_count             = each.value.cluster_auto_scaling_min_count
  max_count             = each.value.cluster_auto_scaling_max_count
}

