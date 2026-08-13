locals {
  availability_domain = coalesce(
    var.availability_domain,
    data.oci_identity_availability_domains.ads.availability_domains[0].name
  )

  image_id = data.oci_core_images.oracle_linux.images[0].id


  name_prefix = var.project_name

  freeform_tags = {
    project = var.project_name
    week    = "2"
    managed = "terraform"
  }

  # Cloud-init script rendered with the mount target's private IP,
  # injected once the mount target resource exists (see compute.tf)
  cloud_init_template = <<-EOT
    #!/bin/bash
    set -e

    MOUNT_TARGET_IP="${oci_file_storage_mount_target.mt.ip_address}"
    EXPORT_PATH="${var.fss_export_path}"
    MOUNT_POINT="${var.fss_export_path}"

    mkdir -p $MOUNT_POINT
    echo "$MOUNT_TARGET_IP:$EXPORT_PATH $MOUNT_POINT nfs nfsvers=3,defaults 0 0" >> /etc/fstab
    mount -a

    mkdir -p $MOUNT_POINT/www
    cat <<'EOF' > $MOUNT_POINT/www/index.html
    <html>
    <head><title>Week2 Lab App</title></head>
    <body>
    <h1>Hello from OCI Private Instance</h1>
    <p>This page is served from a file stored on OCI File Storage Service.</p>
    </body>
    </html>
    EOF

    yum install -y python3
    cd $MOUNT_POINT/www
    nohup python3 -m http.server ${var.app_port} > /var/log/app.log 2>&1 &
  EOT
}
