
resource "oci_containerengine_cluster" "this" {
  compartment_id     = var.compartment_id
  vcn_id             = var.vcn_id
  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version
  freeform_tags      = var.freeform_tags

  dynamic "cluster_pod_network_options" {
    for_each = var.cni_type == "OCI_VCN_IP_NATIVE" ? [1] : []
    content {
      cni_type = "OCI_VCN_IP_NATIVE"
    }
  }

  endpoint_config {
    is_public_ip_enabled = var.is_endpoint_public_ip_enabled
    subnet_id             = var.endpoint_subnet_id
    nsg_ids                = var.endpoint_nsg_ids
  }

  options {
    service_lb_subnet_ids = var.service_lb_subnet_ids

    add_ons {
      is_kubernetes_dashboard_enabled = var.is_kubernetes_dashboard_enabled
    }

    admission_controller_options {
      is_pod_security_policy_enabled = var.is_pod_security_policy_enabled
    }
  }
}


data "oci_containerengine_node_pool_option" "this" {
  node_pool_option_id = oci_containerengine_cluster.this.id
  compartment_id      = var.compartment_id
}

locals {
 
  candidate_sources = [
    for s in data.oci_containerengine_node_pool_option.this.sources :
    s
    if s.source_type == "IMAGE"
    && can(regex(var.node_image_name_regex, s.source_name))
    && !can(regex("aarch64", s.source_name))
    && !can(regex("GPU", s.source_name))
  ]


  candidate_names_sorted = sort([for s in local.candidate_sources : s.source_name])
  latest_source_name     = length(local.candidate_names_sorted) > 0 ? local.candidate_names_sorted[length(local.candidate_names_sorted) - 1] : null

  latest_image_id = local.latest_source_name == null ? null : [
    for s in local.candidate_sources : s.image_id if s.source_name == local.latest_source_name
  ][0]

  resolved_node_image_id = coalesce(var.node_image_id, local.latest_image_id)
}

check "node_image_resolved" {
  assert {
    condition     = local.resolved_node_image_id != null
    error_message = "No compatible OKE node image found for regex '${var.node_image_name_regex}' and kubernetes_version '${var.kubernetes_version}'. Set var.node_image_id explicitly, or adjust node_image_name_regex."
  }
}

resource "oci_containerengine_node_pool" "this" {
  cluster_id          = oci_containerengine_cluster.this.id
  compartment_id      = var.compartment_id
  name                = var.node_pool_name
  kubernetes_version  = var.kubernetes_version
  node_shape          = var.node_shape
  freeform_tags       = var.freeform_tags

  dynamic "node_shape_config" {
    for_each = var.node_shape_config != null ? [var.node_shape_config] : []
    content {
      ocpus         = node_shape_config.value.ocpus
      memory_in_gbs = node_shape_config.value.memory_in_gbs
    }
  }

  node_source_details {
    image_id    = local.resolved_node_image_id
    source_type = "IMAGE"
  }

  node_config_details {
    size = var.node_pool_size

    # One placement_configs{} block per AD supplied by the caller -
    # this is what lets the same module deploy to 1 AD or 3 ADs.
    dynamic "placement_configs" {
      for_each = var.placement_ads
      content {
        availability_domain = placement_configs.value.availability_domain
        subnet_id            = placement_configs.value.subnet_id
      }
    }

   
    dynamic "node_pool_pod_network_option_details" {
      for_each = var.cni_type == "OCI_VCN_IP_NATIVE" ? [1] : []
      content {
        cni_type           = "OCI_VCN_IP_NATIVE"
        pod_subnet_ids     = var.pod_subnet_ids
        pod_nsg_ids        = var.pod_nsg_ids
        max_pods_per_node = var.max_pods_per_node
      }
    }

  
  }

  node_eviction_node_pool_settings {
    eviction_grace_duration = var.node_eviction_grace_duration
  }

  initial_node_labels {
    key   = "managed-by"
    value = "terraform"
  }

  ssh_public_key = var.ssh_public_key

  lifecycle {
    ignore_changes = [
      # avoid perpetual diffs when OKE auto-scales/replaces nodes out of band
      node_config_details[0].size,
    ]
  }
}
