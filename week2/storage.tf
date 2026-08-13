resource "oci_file_storage_file_system" "fs" {
  compartment_id      = var.compartment_id
  availability_domain = local.availability_domain
  display_name        = "fs-app-${local.name_prefix}"
  freeform_tags        = local.freeform_tags
}

resource "oci_file_storage_mount_target" "mt" {
  compartment_id       = var.compartment_id
  availability_domain  = local.availability_domain
  subnet_id            = oci_core_subnet.private.id
  display_name         = "mt-app-${local.name_prefix}"
  freeform_tags        = local.freeform_tags
}

# The mount target automatically provisions its own export set;
# we just attach an export for our file system to it.
resource "oci_file_storage_export" "export" {
  export_set_id  = oci_file_storage_mount_target.mt.export_set_id
  file_system_id = oci_file_storage_file_system.fs.id
  path           = var.fss_export_path
}
