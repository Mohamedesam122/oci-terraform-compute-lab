############################################
# modules/subnet/main.tf
# Resources: Subnet, Route Table, Security List, (optional) Flow Log
############################################

# ---------------------------------------------------------------
# Route Table
# `dynamic "route_rules"` builds one route_rules{} block per entry
# in var.route_rules - no matter how many rules the caller passes.
# ---------------------------------------------------------------
resource "oci_core_route_table" "this" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.subnet_name}-rt"
  freeform_tags  = var.freeform_tags

  dynamic "route_rules" {
    for_each = var.route_rules
    content {
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      network_entity_id = route_rules.value.network_entity_id
    }
  }
}

# ---------------------------------------------------------------
# Security List
# Two dynamic blocks - one for ingress, one for egress - each
# generated from a list of objects passed in by the root module.
# Nested dynamic blocks (tcp_options/udp_options/icmp_options) are
# only rendered `for_each` a value actually exists (conditional).
# ---------------------------------------------------------------
resource "oci_core_security_list" "this" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.subnet_name}-seclist"
  freeform_tags  = var.freeform_tags

  dynamic "ingress_security_rules" {
    for_each = var.ingress_rules
    content {
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      source_type = ingress_security_rules.value.source_type
      description = ingress_security_rules.value.description
      stateless   = ingress_security_rules.value.stateless

      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.tcp_options != null ? [ingress_security_rules.value.tcp_options] : []
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = ingress_security_rules.value.udp_options != null ? [ingress_security_rules.value.udp_options] : []
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = ingress_security_rules.value.icmp_options != null ? [ingress_security_rules.value.icmp_options] : []
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }

  dynamic "egress_security_rules" {
    for_each = var.egress_rules
    content {
      protocol         = egress_security_rules.value.protocol
      destination      = egress_security_rules.value.destination
      destination_type = egress_security_rules.value.destination_type
      description      = egress_security_rules.value.description
      stateless        = egress_security_rules.value.stateless
    }
  }
}

# ---------------------------------------------------------------
# Subnet
# `is_private` drives `prohibit_public_ip_on_vnic` with a plain
# conditional expression - no separate public/private module needed.
# ---------------------------------------------------------------
resource "oci_core_subnet" "this" {
  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  cidr_block                 = var.cidr_block
  display_name               = var.subnet_name
  dns_label                  = var.dns_label
  prohibit_public_ip_on_vnic = var.is_private
  route_table_id             = oci_core_route_table.this.id
  security_list_ids          = [oci_core_security_list.this.id]
  freeform_tags              = var.freeform_tags
}

# ---------------------------------------------------------------
# Enable Logs (VCN Flow Logs) - CONDITIONAL RESOURCE
# count = 0 or 1 based on a boolean var. When disabled, the
# resource simply doesn't exist in the plan/state.
# ---------------------------------------------------------------
resource "oci_logging_log" "flow_log" {
  count = var.enable_flow_logs ? 1 : 0

  display_name = "${var.subnet_name}-flow-log"
  log_group_id = var.log_group_id
  log_type     = "SERVICE"
  is_enabled   = true
  retention_duration = var.flow_log_retention_days

  configuration {
    source {
      category    = "all"
      resource    = oci_core_subnet.this.id
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_id
  }

  freeform_tags = var.freeform_tags
}
