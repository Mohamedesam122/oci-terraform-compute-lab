
resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "sl-public-${local.name_prefix}"

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      min = var.lb_listener_port
      max = var.lb_listener_port
    }
  }

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    stateless        = false
  }

  freeform_tags = local.freeform_tags
}


resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "sl-private-${local.name_prefix}"

  # LB -> App traffic
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.public_subnet_cidr
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      min = var.app_port
      max = var.app_port
    }
  }

  # SSH (bastion access)
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  # NFS - port 2049
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      min = 2049
      max = 2049
    }
  }

  # NFS - portmapper 111
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      min = 111
      max = 111
    }
  }

  # NFS - mount protocol 2048
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      min = 2048
      max = 2048
    }
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    stateless        = false
  }

  freeform_tags = local.freeform_tags
}
