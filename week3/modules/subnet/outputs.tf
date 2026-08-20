
output "subnet_id" {
  description = "OCID of the created subnet."
  value       = oci_core_subnet.this.id
}

output "route_table_id" {
  description = "OCID of the created route table."
  value       = oci_core_route_table.this.id
}

output "security_list_id" {
  description = "OCID of the created security list."
  value       = oci_core_security_list.this.id
}

output "flow_log_id" {
  description = "OCID of the flow log, if enabled. Null otherwise."
  value       = var.enable_flow_logs ? oci_logging_log.flow_log[0].id : null
}

output "cidr_block" {
  description = "CIDR block of the created subnet (handy for wiring into other modules, e.g. security rules)."
  value       = oci_core_subnet.this.cidr_block
}
