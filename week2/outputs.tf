output "vcn_id" {
  description = "OCID of the created VCN"
  value       = oci_core_vcn.this.id
}

output "public_subnet_id" {
  value = oci_core_subnet.public.id
}

output "private_subnet_id" {
  value = oci_core_subnet.private.id
}

output "instance_id" {
  value = oci_core_instance.app.id
}

output "instance_private_ip" {
  value = oci_core_instance.app.private_ip
}

output "mount_target_private_ip" {
  value = oci_file_storage_mount_target.mt.ip_address
}

output "load_balancer_public_ip" {
  description = "Public IP address of the load balancer - open this in a browser to test"
  value       = oci_load_balancer_load_balancer.app.ip_address_details[0].ip_address
}
