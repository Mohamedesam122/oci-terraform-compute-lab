resource "oci_load_balancer_load_balancer" "app" {
  compartment_id = var.compartment_id
  display_name   = "lb-app-${local.name_prefix}"
  shape          = "flexible"

  shape_details {
    minimum_bandwidth_in_mbps = var.lb_min_bandwidth_mbps
    maximum_bandwidth_in_mbps = var.lb_max_bandwidth_mbps
  }

  subnet_ids = [oci_core_subnet.public.id]
  is_private = false

  freeform_tags = local.freeform_tags
}

resource "oci_load_balancer_backend_set" "app" {
  name             = "bs-app-${local.name_prefix}"
  load_balancer_id = oci_load_balancer_load_balancer.app.id
  policy           = "WEIGHTED_ROUND_ROBIN"

  health_checker {
    protocol            = "HTTP"
    port                = var.app_port
    url_path            = "/"
    return_code         = 200
    interval_ms         = 10000
    timeout_in_millis   = 3000
    retries             = 3
  }
}

resource "oci_load_balancer_backend" "app" {
  load_balancer_id = oci_load_balancer_load_balancer.app.id
  backendset_name   = oci_load_balancer_backend_set.app.name
  ip_address        = oci_core_instance.app.private_ip
  port              = var.app_port
}

resource "oci_load_balancer_listener" "app" {
  load_balancer_id         = oci_load_balancer_load_balancer.app.id
  name                     = "listener-app-${local.name_prefix}"
  default_backend_set_name = oci_load_balancer_backend_set.app.name
  port                     = var.lb_listener_port
  protocol                 = "HTTP"
}
