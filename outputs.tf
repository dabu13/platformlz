output "resource_group_name" {
  description = "The resource group containing the AKS deployment."
  value       = azurerm_resource_group.rg.name
}

output "cluster_name" {
  description = "The AKS cluster name."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "cluster_fqdn" {
  description = "The Kubernetes API server FQDN."
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "kubelet_identity_object_id" {
  description = "Object ID of the AKS kubelet identity."
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
