

locals {
  name_prefix = "${var.environment}-oke"

  common_tags = {
    environment = var.environment
    managed_by  = "terraform"
    project     = "week3-oke"
  }
}



# 1) Kubernetes API endpoint subnet (public or private depending on env)
module "endpoint_subnet" {
  source = "../../modules/subnet"

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  subnet_name    = "${local.name_prefix}-endpoint"
  dns_label      = "okeendpoint"
  cidr_block     = "10.0.0.0/28"
  is_private     = false

  route_rules = [
    {
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_internet_gateway.this.id
    }
  ]

  ingress_rules = [
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      description = "Kubernetes API server HTTPS"
      tcp_options = { min = 6443, max = 6443 }
    },
    {
      protocol    = "6"
      source      = var.vcn_cidr
      description = "Worker-to-control-plane"
      tcp_options = { min = 12250, max = 12250 }
    },
    {
      protocol     = "1"
      source       = var.vcn_cidr
      description  = "Path MTU Discovery (ICMP Type 3, Code 4)"
      icmp_options = { type = 3, code = 4 }
    }
  ]

  enable_flow_logs = true
  log_group_id     = oci_logging_log_group.this.id
  freeform_tags    = local.common_tags
}

# 2) Worker node subnet (private)
module "node_subnet" {
  source = "../../modules/subnet"

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  subnet_name    = "${local.name_prefix}-nodes"
  dns_label      = "okenodes"
  cidr_block     = "10.0.1.0/24"
  is_private     = true

  route_rules = [
    {
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_nat_gateway.this.id
    },
    {
      destination       = data.oci_core_services.all_oci_services.services[0].cidr_block
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.this.id
    }
  ]

  ingress_rules = [
    {
      protocol    = "all"
      source      = var.vcn_cidr
      description = "Allow all traffic within the VCN (nodes/pods/control plane)"
    },
    {
      protocol     = "1"
      source       = "0.0.0.0/0"
      description  = "Path MTU Discovery (ICMP Type 3, Code 4)"
      icmp_options = { type = 3, code = 4 }
    }
  ]

  enable_flow_logs = true
  log_group_id     = oci_logging_log_group.this.id
  freeform_tags    = local.common_tags
}

# 3) Pod subnet (VCN-native pod networking needs its own IP range)
module "pod_subnet" {
  source = "../../modules/subnet"

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  subnet_name    = "${local.name_prefix}-pods"
  dns_label      = "okepods"
  cidr_block     = "10.0.8.0/21"
  is_private     = true

  route_rules = [
    {
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_nat_gateway.this.id
    },
    {
      destination       = data.oci_core_services.all_oci_services.services[0].cidr_block
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.this.id
    }
  ]

  ingress_rules = [
    {
      protocol    = "all"
      source      = var.vcn_cidr
      description = "Allow all pod-to-pod / pod-to-node traffic"
    },
    {
      protocol     = "1"
      source       = "0.0.0.0/0"
      description  = "Path MTU Discovery (ICMP Type 3, Code 4)"
      icmp_options = { type = 3, code = 4 }
    }
  ]

  enable_flow_logs = false # example of the conditional resource NOT being created
  freeform_tags    = local.common_tags
}

# 4) Load Balancer subnet (public, for the Service type=LoadBalancer in the lab)
module "lb_subnet" {
  source = "../../modules/subnet"

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  subnet_name    = "${local.name_prefix}-lb"
  dns_label      = "okelb"
  cidr_block     = "10.0.20.0/24"
  is_private     = false

  route_rules = [
    {
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_internet_gateway.this.id
    }
  ]

  ingress_rules = [
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      description = "Public HTTP"
      tcp_options = { min = 80, max = 80 }
    },
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      description = "Public HTTPS"
      tcp_options = { min = 443, max = 443 }
    }
  ]

  enable_flow_logs = true
  log_group_id     = oci_logging_log_group.this.id
  freeform_tags    = local.common_tags
}


module "oke" {
  source = "../../modules/oke"

  compartment_id     = var.compartment_id
  vcn_id             = oci_core_vcn.this.id
  cluster_name       = "${local.name_prefix}-cluster"
  kubernetes_version = var.kubernetes_version

  endpoint_subnet_id            = module.endpoint_subnet.subnet_id
  is_endpoint_public_ip_enabled = true

  cni_type       = "OCI_VCN_IP_NATIVE"
  pod_subnet_ids = [module.pod_subnet.subnet_id]

  service_lb_subnet_ids = [module.lb_subnet.subnet_id]

  node_pool_name = "${local.name_prefix}-pool"
  node_shape     = "VM.Standard.E4.Flex"
  node_shape_config = {
    ocpus         = 2
    memory_in_gbs = 16
  }

  ssh_public_key = var.ssh_public_key
  node_pool_size = length(var.availability_domains) # one node per AD, scales automatically

  placement_ads = [
    for ad in var.availability_domains : {
      availability_domain = ad
      subnet_id           = module.node_subnet.subnet_id
    }
  ]

  freeform_tags = local.common_tags
}
