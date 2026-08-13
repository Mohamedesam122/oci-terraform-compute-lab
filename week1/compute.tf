
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "9"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}


resource "oci_core_instance" "lab1_instance" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name         = "lab1-instance-tf"
  shape                = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.lab1_public_subnet.id
    assign_public_ip           = true
    display_name               = "lab1-vnic-tf"
    assign_private_dns_record  = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.oracle_linux.images[0].id
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
}


resource "oci_core_volume" "lab1_block_volume" {
  compartment_id      = var.compartment_ocid
  availability_domain  = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name         = "lab1-block-volume-tf"
  size_in_gbs           = var.block_volume_size_in_gbs
}


resource "oci_core_volume_attachment" "lab1_volume_attachment" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.lab1_instance.id
  volume_id       = oci_core_volume.lab1_block_volume.id
}
