############################################
# environments/dev/network.tf
# The assignment's modules (subnet, oke) intentionally do NOT create
# the VCN itself - a VCN is a one-time-per-environment resource, not
# something you'd parameterize and re-call like a subnet. So it lives
# here in the root config and its outputs feed into modules/subnet
# and modules/oke as plain values.
############################################

resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_id
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${local.name_prefix}-vcn"
  dns_label      = "okevcn"
  freeform_tags  = local.common_tags
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${local.name_prefix}-igw"
  enabled        = true
  freeform_tags  = local.common_tags
}

resource "oci_core_nat_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${local.name_prefix}-nat"
  freeform_tags  = local.common_tags
}

# Lets private subnets reach OCI public services (e.g. OCIR, Object
# Storage) without going through the NAT gateway / public internet.
data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${local.name_prefix}-sgw"
  freeform_tags  = local.common_tags

  services {
    service_id = data.oci_core_services.all_oci_services.services[0].id
  }
}

resource "oci_logging_log_group" "this" {
  compartment_id = var.compartment_id
  display_name   = "${local.name_prefix}-log-group"
  freeform_tags  = local.common_tags
}
