resource "oci_core_vcn" "lab1_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = var.vcn_cidr_block
  display_name   = "lab1-vcn-tf"
  dns_label      = "lab1vcntf"
}


resource "oci_core_internet_gateway" "lab1_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab1_vcn.id
  display_name   = "lab1-igw-tf"
  enabled        = true
}

resource "oci_core_route_table" "lab1_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab1_vcn.id
  display_name   = "lab1-route-table-tf"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.lab1_igw.id
  }
}


resource "oci_core_security_list" "lab1_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab1_vcn.id
  display_name   = "lab1-security-list-tf"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6" # TCP
    tcp_options {
      min = 22
      max = 22
    }
  }
}


resource "oci_core_subnet" "lab1_public_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.lab1_vcn.id
  cidr_block                 = var.subnet_cidr_block
  display_name                = "public-subnet-lab1-tf"
  dns_label                  = "publicsubtf"
  route_table_id              = oci_core_route_table.lab1_route_table.id
  security_list_ids           = [oci_core_security_list.lab1_security_list.id]
  prohibit_public_ip_on_vnic  = false
}
