# Availability domains in the region/compartment
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Latest Oracle Linux 8 image matching the chosen shape
data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order                = "DESC"
}
