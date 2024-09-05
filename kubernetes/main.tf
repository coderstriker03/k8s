variable "mysql_server_admin_password" {}

###### vnet creation ####
# Resource Group for Production
resource "azurerm_resource_group" "res-0" {
  #name     = "MC_k8s_k8s-qa-cluster_eastus"
  #name     = "MC_k8s_k8s-qa-cluster_eastus"
  name     = "k8s"
  location = "eastus"
}


# Resource Group for QA
resource "azurerm_resource_group" "res-4" {
  #name     = "regask-qa-side"
  name     = "wordpress-qa-side"
  location = "eastus"
}

# qa Network Module
module "network" {
  source              = "./modules/network"
  virtual_network_address_space = ["10.0.0.0/8"]
  virtual_network_location      = "eastus"
  #virtual_network_name          = "aks-vnet-66166059"
  virtual_network_name          = "aks-vnet-661660592"
  resource_group_name           = azurerm_resource_group.res-0.name

  subnets = {
    "aks-subnet" = {
      address_prefixes  = ["10.240.0.0/16"]
      service_endpoints = []
      delegation = null
    }
  }

  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

# QA Network Module
module "network_qa" {
  source              = "./modules/network"
  virtual_network_address_space = ["172.16.0.0/16"]
  virtual_network_location      = "eastus"
  virtual_network_name          = "wordpress-qa-side-vnet"
  resource_group_name           = azurerm_resource_group.res-4.name

  subnets = {
    "mysqls" = {
      address_prefixes = ["172.16.0.0/24"]
      service_endpoints = []
      delegation = {
        name = "Microsoft.DBforMySQL.flexibleServers"
        service_delegation = {
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          name    = "Microsoft.DBforMySQL/flexibleServers"
        }
      }
    }
  }

  depends_on = [
    azurerm_resource_group.res-4,
  ]
}



#Virtual Network Peering for aks vnet
resource "azurerm_virtual_network_peering" "res-28" {
  allow_forwarded_traffic   = true
  name                      = "aks-qa-link"
  remote_virtual_network_id = module.network_qa.virtual_network_id
  resource_group_name       = azurerm_resource_group.res-0.name
  virtual_network_name      = module.network.virtual_network_name

  depends_on = [
    module.network,
    module.network_qa
  ]
}

# Virtual Network Peering for QA normal vnet
resource "azurerm_virtual_network_peering" "res-564" {
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
  name                      = "qa-aks-link"
  remote_virtual_network_id = module.network.virtual_network_id
  resource_group_name       = azurerm_resource_group.res-4.name
  virtual_network_name      = module.network_qa.virtual_network_name

  depends_on = [
    module.network,
    module.network_qa
  ]
}


###### kubernetes cluster ####
module "k8s_qa_cluster" {
  source              = "./modules/kubernetes"
  #name                = "k8s-qa-cluster"
  name                = "k8s-qa-clusteccr"
  node_resource_group = "MC_k8s_k8s-qa-cluster_eastus"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.res-0.name
  dns_prefix          = "qa"
  kubernetes_version  = "1.28.10"
  
  default_node_pool_name          = "k8sndpoolqa"
  default_node_count              = 2
  #default_vm_size                 = "Standard_B4ms"
  default_vm_size                 = "Standard_B2s"
  default_os_disk_size_gb         = 64
  default_os_disk_type            = "Managed"
  default_kubelet_disk_type       = "OS"
  default_max_pods                = 110
  default_node_type               = "VirtualMachineScaleSets"
  default_enable_auto_scaling     = false
  default_scale_down_mode         = "Delete"
  default_orchestrator_version    = "1.28.10"
  default_enable_node_public_ip   = false
  default_mode                    = "System"
  default_os_sku                  = "Ubuntu"
  
  vnet_subnet_id                  = module.network.subnets["aks-subnet"]
  

  additional_pool_name            = "ds2nodepool"
  additional_node_count           = 2
  additional_vm_size              = "Standard_D4s_v3"
  additional_os_disk_size_gb      = 128
  additional_os_disk_type         = "Managed"
  additional_kubelet_disk_type    = "OS"
  additional_max_pods             = 11
  additional_node_type            = "VirtualMachineScaleSets"
  additional_enable_auto_scaling  = false
  additional_scale_down_mode      = "Delete"
  additional_orchestrator_version = "1.28.10"
  additional_enable_node_public_ip= false
  additional_mode                 = "User"
  additional_os_type              = "Linux"
  additional_os_sku               = "Ubuntu"
  network_plugin      = "kubenet"
  network_policy      = null
  load_balancer_sku   = "standard"
  service_cidr        = "10.0.0.0/16"
  dns_service_ip      = "10.0.0.10"
  docker_bridge_cidr  = "172.17.0.1/16"
  outbound_type       = "loadBalancer"
  use_aad_auth        = "true"
  
  tags = {
    Project      = "qa"
    Environment  = "qa"
    Status       = "Managed by Terraform"
  }
  
}


###### mysql ####
module "mysql_qa" {
  source                  = "./modules/mysql_flexible_server"
  #mysql_server_name       = "regask-qa-mysql"
  mysql_server_name       = "wordpress-qa-mysql2"
  #
  #location                =  "East US 2"
  location                =  "Central US"

  #resource_group_name     = "regask-qa-side"
  #resource_group_name     = azurerm_resource_group.res-4.name
  # resource_group_name     = "test"
  resource_group_name     = azurerm_resource_group.res-4.name
  mysql_server_admin_login    = "dbadmin"
  mysql_server_admin_password = var.mysql_server_admin_password  # Password should be securely stored and retrieved
  mysql_version           = "8.0.21"
  #
  sku_name                = "B_Standard_B1ms"
  # delegated_subnet_id =  module.network_qa.subnets["mysqls"]

  storage = {
    auto_grow_enabled  = true
    size_gb            = 20  # 20 GB
    io_scaling_enabled = false
    iops               = 360
  }

  backup_retention_days   = 7

  tags = {}
}
# create acr Container registery
resource "azurerm_container_registry" "acr" {
  name                = "wordpresscontainerRegistry"
  location            = azurerm_resource_group.res-0.location
  resource_group_name = azurerm_resource_group.res-0.name
  sku                 = "Standard"
  admin_enabled       = false
}

data "azurerm_kubernetes_cluster" "get_data_from_aks" {
  name                = module.k8s_qa_cluster.kubernetes_cluster_name
  resource_group_name = module.k8s_qa_cluster.kubernetes_resource_group_name
  depends_on = [
    module.k8s_qa_cluster
  ]
}


#resource "azurerm_role_assignment" "example" {
#  principal_id                     = azurerm_kubernetes_cluster.k8s_qa_cluster.kubelet_identity[0].object_id
#  role_definition_name             = "AcrPull"
#  scope                            = azurerm_container_registry.acr.id
#  #skip_service_principal_aad_check = true
#  depends_on = [
#    module.k8s_qa_cluster,
#	azurerm_container_registry.acr
#  ]
#}


resource "azurerm_role_assignment" "managedidentity" {
  principal_id                     = module.k8s_qa_cluster.kubelet_identity_object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
  depends_on = [
    module.k8s_qa_cluster,
    azurerm_container_registry.acr
  ]
}
