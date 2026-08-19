############################################
# environments/dev/outputs.tf
############################################

output "cluster_id" {
  value = module.oke.cluster_id
}

output "node_pool_id" {
  value = module.oke.node_pool_id
}

output "kubeconfig_command" {
  description = "Run this after apply to fetch kubeconfig via OCI CLI."
  value       = "oci ce cluster create-kubeconfig --cluster-id ${module.oke.cluster_id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0"
}

output "node_subnet_id" { value = module.node_subnet.subnet_id }
output "pod_subnet_id" { value = module.pod_subnet.subnet_id }
output "lb_subnet_id" { value = module.lb_subnet.subnet_id }
output "endpoint_subnet_id" { value = module.endpoint_subnet.subnet_id }
output "vcn_id" { value = oci_core_vcn.this.id }
output "log_group_id" { value = oci_logging_log_group.this.id }
output "resolved_node_image_id" {
  description = "The worker node image OCID actually used (auto-resolved unless node_image_id was set)."
  value       = module.oke.resolved_node_image_id
}
