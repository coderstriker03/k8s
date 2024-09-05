terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.14.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.115.0"
    }
  }
}



provider "azurerm" {
  features {}

  subscription_id = "d80c4f43-48c0-4d42-b41f-4d3db0069cb6"
  client_id       = "b6805b51-3b11-44c4-a1c8-67b779627227"
  client_secret   = "H..8Q~C6iA9paJc1gJwLIVvov3Qm-1sJpaU_odha"
  tenant_id       = "78c0f350-afab-4197-b030-f1cad0dbbc2b"
} 


data "azurerm_kubernetes_cluster" "default" {
  name                = var.cluster_name
  resource_group_name = var.rg_name
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
  }
}

resource "azurerm_public_ip" "ingress_nginx_pip" {
  name                = "ingress-nginx-pip"
  location            = var.cluster_location
  resource_group_name = "MC_k8s_k8s-qa-cluster_eastus"
  allocation_method   = "Static"
  sku                 = "Standard"
}

data "azurerm_public_ip" "ingress_nginx_pip" {
  name                = azurerm_public_ip.ingress_nginx_pip.name
  resource_group_name = "MC_k8s_k8s-qa-cluster_eastus"
  depends_on = [
    azurerm_public_ip.ingress_nginx_pip
  ]
}

### ingress dns zone ####
#resource "azurerm_dns_zone" "ingress_zone" {
#  name                = anaghimbensouissi.ovh
#  resource_group_name = "MC_k8s_k8s-qa-cluster_eastus"
#}

data "azurerm_dns_zone" "ingress_zone" {
  name = "anaghimbensouissi.ovh"
  resource_group_name ="mytest-rg"
    depends_on = [
    azurerm_public_ip.ingress_nginx_pip
  ]
}


locals {
ingress_zone_name = data.azurerm_dns_zone.ingress_zone.name
}


resource "azurerm_dns_a_record" "ingress" {
  name                = "app"
  zone_name           = data.azurerm_dns_zone.ingress_zone.name
  resource_group_name = data.azurerm_dns_zone.ingress_zone.resource_group_name
  ttl                 = 3600
  records             = [data.azurerm_public_ip.ingress_nginx_pip.ip_address]
  depends_on = [
    data.azurerm_dns_zone.ingress_zone
  ]
}


resource "kubernetes_namespace" "test" {
  metadata {
    name = "ingresses"
  }
}

#resource "kubernetes_deployment" "test" {
#  metadata {
#    name      = "test"
#    namespace = kubernetes_namespace.test.metadata.0.name
#  }
#  spec {
#    replicas = 2
#    selector {
#      match_labels = {
#        app = "test"
#      }
#    }
#    template {
#      metadata {
#        labels = {
#          app = "test"
#        }
#      }
#      spec {
#        container {
#          image = "nginx:1.19.4"
#          name  = "nginx"
#          resources {
#            limits = {
#              memory = "512M"
#              cpu    = "1"
#            }
#            requests = {
#              memory = "256M"
#              cpu    = "50m"
#            }
#          }
#        }
#      }
#    }
#  }
#}

  
locals {
ingress_nginx_pip_ip = data.azurerm_public_ip.ingress_nginx_pip.ip_address
}



resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-controller"
  repository = "https://charts.bitnami.com/bitnami"
  #repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "nginx-ingress-controller"
  namespace        = "ingresses"
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "ingressClassResource.name"
    value = "ingress-nginx"
  }
  set {
    name  = "service.loadBalancerIP"
    value = local.ingress_nginx_pip_ip
  }

  depends_on = [
    azurerm_public_ip.ingress_nginx_pip
  ]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.15.3"
  namespace        = "ingresses"
  #create_namespace = true
  

  set {
    name  = "installCRDs"
    value = "true"
  }
depends_on = [
    azurerm_public_ip.ingress_nginx_pip
  ]  
}
resource "local_file" "kubeconfig" {
  content  = var.kubeconfig
  filename = "${path.root}/kubeconfig"
}
