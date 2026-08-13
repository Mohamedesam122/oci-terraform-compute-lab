resource "oci_core_instance" "app" {
  compartment_id      = var.compartment_id
  availability_domain = local.availability_domain
  display_name        = "inst-app-${local.name_prefix}"
  shape                = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.private.id
    assign_public_ip = false
    display_name     = "vnic-app-${local.name_prefix}"
  }

  source_details {
    source_type = "image"
    source_id   = local.image_id
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = base64encode(local.cloud_init_template)
  }

  # Make sure the FSS mount target + export exist before the instance
  # boots and tries to mount them via cloud-init
  depends_on = [
    oci_file_storage_export.export,
    oci_file_storage_mount_target.mt,
  ]

  freeform_tags = local.freeform_tags

  lifecycle {
    ignore_changes = [
      # avoid unnecessary replacement if OCI updates the image list
      source_details[0].source_id,
    ]
  }
}
