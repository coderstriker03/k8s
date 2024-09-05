variable "name" {
  description = "The name of the Kubernetes cluster"
}

variable "location" {
  description = "Azure location"
}

variable "resource_group_name" {
  description = "The name of the resource group"
}

variable "node_resource_group" {
  description = "The name of the resource group"
}

variable "dns_prefix" {
  description = "DNS prefix for the Kubernetes cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the cluster"
}

variable "default_node_pool_name" {
  description = "The name of the default node pool"
}

variable "default_node_count" {
  description = "The number of nodes in the default node pool"
}

variable "default_vm_size" {
  description = "The size of the virtual machines in the default node pool"
}

variable "default_os_disk_size_gb" {
  description = "OS disk size in GB for the default node pool"
}

variable "default_os_disk_type" {
  description = "OS disk type for the default node pool"
}

variable "default_kubelet_disk_type" {
  description = "Kubelet disk type for the default node pool"
}

variable "default_max_pods" {
  description = "Maximum number of pods per node for the default node pool"
}

variable "default_node_type" {
  description = "Type of node for the default node pool"
}

variable "default_enable_auto_scaling" {
  description = "Enable auto-scaling for the default node pool"
}

variable "default_scale_down_mode" {
  description = "Scale down mode for the default node pool"
}

variable "default_orchestrator_version" {
  description = "Orchestrator version for the default node pool"
}

variable "default_enable_node_public_ip" {
  description = "Enable public IP for nodes in the default node pool"
}

variable "default_mode" {
  description = "Mode for the default node pool"
}

#variable "default_os_type" {
#  description = "OS type for the default node pool"
#}

variable "default_os_sku" {
  description = "OS SKU for the default node pool"
}

#variable "default_node_image_version" {
#  description = "Node image version for the default node pool"
#}

variable "additional_pool_name" {
  description = "The name of the additional node pool"
}

variable "additional_node_count" {
  description = "The number of nodes in the additional node pool"
}

variable "additional_vm_size" {
  description = "The size of the virtual machines in the additional node pool"
}

variable "additional_os_disk_size_gb" {
  description = "OS disk size in GB for the additional node pool"
}

variable "additional_os_disk_type" {
  description = "OS disk type for the additional node pool"
}

variable "additional_kubelet_disk_type" {
  description = "Kubelet disk type for the additional node pool"
}

variable "additional_max_pods" {
  description = "Maximum number of pods per node for the additional node pool"
}

variable "additional_node_type" {
  description = "Type of node for the additional node pool"
}

variable "additional_enable_auto_scaling" {
  description = "Enable auto-scaling for the additional node pool"
}

variable "additional_scale_down_mode" {
  description = "Scale down mode for the additional node pool"
}

variable "additional_orchestrator_version" {
  description = "Orchestrator version for the additional node pool"
}

variable "additional_enable_node_public_ip" {
  description = "Enable public IP for nodes in the additional node pool"
}

variable "additional_mode" {
  description = "Mode for the additional node pool"
}

variable "additional_os_type" {
  description = "OS type for the additional node pool"
}

variable "additional_os_sku" {
  description = "OS SKU for the additional node pool"
}

#variable "additional_node_image_version" {
#  description = "Node image version for the additional node pool"
#}

variable "network_plugin" {
  description = "Network plugin to use for networking"
}

variable "network_policy" {
  description = "Network policy to use for networking"
}

variable "load_balancer_sku" {
  description = "The SKU of the load balancer"
}

variable "service_cidr" {
  description = "The CIDR to use for service IP addresses"
}

variable "dns_service_ip" {
  description = "The IP address within the service CIDR to use for DNS"
}

variable "docker_bridge_cidr" {
  description = "The CIDR to use for the Docker bridge network"
}

variable "outbound_type" {
  description = "The outbound type for network traffic"
}

#variable "log_analytics_workspace_id" {
#  description = "The ID of the Log Analytics workspace"
#}

variable "use_aad_auth" {
  description = "Use AAD authentication for OMS agent"
}

variable "tags" {
  description = "Tags to apply to the resources"
}

variable "additional_node_pools" {
  description = "The map object to configure one or several additional node pools with number of worker nodes, worker node VM size and Availability Zones."
  type = map(object({
    node_name                      = string
    node_count                     = number
    vm_size                        = string
    zones                          = list(string)
    node_os                        = string
    taints                         = list(string)
    cluster_auto_scaling           = bool
    cluster_auto_scaling_min_count = number
    cluster_auto_scaling_max_count = number
  }))
  default = {}
}

variable "vnet_subnet_id" {
  description = "The ID of the subnet within the virtual network to which the Kubernetes cluster nodes will be connected."
  type        = string
}
