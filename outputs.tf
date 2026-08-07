output "instance_public_ip" {
  description = "Public IP address of the compute instance"
  value       = oci_core_instance.lab1_instance.public_ip
}

output "instance_id" {
  description = "OCID of the compute instance"
  value       = oci_core_instance.lab1_instance.id
}

output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.lab1_vcn.id
}

output "subnet_id" {
  description = "OCID of the public subnet"
  value       = oci_core_subnet.lab1_public_subnet.id
}

output "block_volume_id" {
  description = "OCID of the block volume"
  value       = oci_core_volume.lab1_block_volume.id
}

output "ssh_connection_command" {
  description = "Ready-to-use SSH command to connect to the instance"
  value       = "ssh -i C:/OCI/ssh-key-2026-08-06.key opc@${oci_core_instance.lab1_instance.public_ip}"
}
