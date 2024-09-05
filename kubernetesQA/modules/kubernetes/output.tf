output "kube_admin_config" {
  value = azurerm_kubernetes_cluster.k8s.kube_admin_config_raw
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.k8s.kube_config_raw
}

# 
output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "kubernetes_resource_group_name" {
  value = azurerm_kubernetes_cluster.k8s.resource_group_name
}

output "kubernetes_location" {
  value = azurerm_kubernetes_cluster.k8s.location
}

output "kubernetes_cluster_id" {
  value = azurerm_kubernetes_cluster.k8s.id
}

output "kubelet_identity_object_id" {
  value = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
}