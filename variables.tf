variable "location" {
  description = "Azure region for the deployment."
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Name of the resource group that will contain the AKS resources."
  type        = string
  default     = "rg-aks-secure-eastus2"
}

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "aks-secure-eastus2"
}

variable "node_count" {
  description = "Number of nodes in the default system node pool."
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "VM SKU for the AKS nodes. Set this to match the SKU used by your IACAzure environment."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "node_os_sku" {
  description = "AKS node image family. This is the closest AKS equivalent to selecting the image family used by IACAzure."
  type        = string
  default     = "Ubuntu"
}

variable "kubernetes_version" {
  description = "Optional AKS kubernetes version. Leave null to use the default recommended version."
  type        = string
  default     = null
}

variable "vnet_address_space" {
  description = "Address space for the AKS virtual network."
  type        = string
  default     = "10.20.0.0/16"
}

variable "aks_subnet_address_prefix" {
  description = "Address prefix for the AKS subnet."
  type        = string
  default     = "10.20.1.0/24"
}

variable "service_cidr" {
  description = "CIDR used for Kubernetes services inside the cluster."
  type        = string
  default     = "10.21.0.0/16"
}

variable "dns_service_ip" {
  description = "Cluster DNS service IP address."
  type        = string
  default     = "10.21.0.10"
}

variable "private_cluster_enabled" {
  description = "Deploy the cluster as a private AKS cluster for a more secure control-plane design."
  type        = bool
  default     = true
}

variable "authorized_ip_ranges" {
  description = "Optional list of CIDR ranges allowed to reach the AKS API server when not using a private cluster."
  type        = list(string)
  default     = []
}

variable "log_analytics_retention_in_days" {
  description = "Retention for the Log Analytics workspace."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Resource tags to apply to all resources."
  type        = map(string)
  default     = {}
}
