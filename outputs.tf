output "resource_group_name" {
  description = "The resource group containing the AKS deployment."
  value       = azurerm_resource_group.this.name
}

output "cluster_name" {
  description = "The AKS cluster name."
  value       = azurerm_kubernetes_cluster.this.name
}

output "cluster_fqdn" {
  description = "The Kubernetes API server FQDN."
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "kubelet_identity_object_id" {
  description = "Object ID of the AKS kubelet identity."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
