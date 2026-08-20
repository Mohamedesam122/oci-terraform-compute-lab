

output "cluster_id" {
  description = "OCID of the OKE cluster."
  value       = oci_containerengine_cluster.this.id
}

output "cluster_kubernetes_version" {
  value = oci_containerengine_cluster.this.kubernetes_version
}

output "node_pool_id" {
  description = "OCID of the managed node pool."
  value       = oci_containerengine_node_pool.this.id
}

output "cni_type" {
  value = var.cni_type
}

output "resolved_node_image_id" {
  description = "The worker node image OCID that was used - either var.node_image_id if set, or the auto-resolved latest compatible OKE image."
  value       = local.resolved_node_image_id
}
