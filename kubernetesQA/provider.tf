provider "azurerm" {
  features {}

  subscription_id = "d80c4f43-48c0-4d42-b41f-4d3db0069cb6"
  client_id       = "b6805b51-3b11-44c4-a1c8-67b779627227"
  client_secret   = "H..8Q~C6iA9paJc1gJwLIVvov3Qm-1sJpaU_odha"
  tenant_id       = "78c0f350-afab-4197-b030-f1cad0dbbc2b"
} 
#
# provider "kubernetes" {
#   host                   = data.azurerm_kubernetes_cluster.get_data_from_aks.kube_config[0].host
#   client_certificate     = base64decode(data.azurerm_kubernetes_cluster.get_data_from_aks.kube_config[0].client_certificate)
#   client_key             = base64decode(data.azurerm_kubernetes_cluster.get_data_from_aks.kube_config[0].client_key)
#   cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.get_data_from_aks.kube_config[0].cluster_ca_certificate)
# }

# provider "helm" {
#   kubernetes {
#     host                   = data.azurerm_kubernetes_cluster.get_data_from_aks.kube_config[0].host
#     client_certificate     = base64decode(data.azurerm_kubernetes_cluster.get_data_from_aks.kube_config[0].client_certificate)
#     client_key             = base64decode(data.azurerm_kubernetes_cluster.get_data_from_aks.kube_config[0].client_key)
#     cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.get_data_from_aks.kube_config[0].cluster_ca_certificate)
#   }
# }