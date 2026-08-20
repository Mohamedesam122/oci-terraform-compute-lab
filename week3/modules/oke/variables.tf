
variable "compartment_id" {
  description = "OCID of the compartment for the OKE cluster and node pool."
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN the cluster runs in."
  type        = string
}

variable "cluster_name" {
  description = "Display name of the OKE cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster control plane, e.g. v1.29.1."
  type        = string
}

variable "endpoint_subnet_id" {
  description = "OCID of the subnet used for the Kubernetes API endpoint."
  type        = string
}

variable "is_endpoint_public_ip_enabled" {
  description = "Whether the Kubernetes API endpoint gets a public IP."
  type        = bool
  default     = false
}

variable "endpoint_nsg_ids" {
  description = "Optional list of NSG OCIDs for the API endpoint."
  type        = list(string)
  default     = []
}
variable "cni_type" {
  description = "CNI type for the cluster/node pool: OCI_VCN_IP_NATIVE (VCN-native pod networking) or FLANNEL_OVERLAY."
  type        = string
  default     = "OCI_VCN_IP_NATIVE"

  validation {
    condition     = contains(["OCI_VCN_IP_NATIVE", "FLANNEL_OVERLAY"], var.cni_type)
    error_message = "cni_type must be either OCI_VCN_IP_NATIVE or FLANNEL_OVERLAY."
  }
}

variable "pod_subnet_ids" {
  description = "Subnet OCID(s) used for pod IPs. Required when cni_type = OCI_VCN_IP_NATIVE, ignored otherwise."
  type        = list(string)
  default     = []
}

variable "pod_nsg_ids" {
  description = "Optional NSG OCIDs applied to pod VNICs (VCN-native only)."
  type        = list(string)
  default     = []
}

variable "max_pods_per_node" {
  description = "Max pods per node (VCN-native only)."
  type        = number
  default     = 31
}


variable "is_kubernetes_dashboard_enabled" {
  type    = bool
  default = false
}

variable "is_pod_security_policy_enabled" {
  type    = bool
  default = false
}

variable "service_lb_subnet_ids" {
  description = "Subnet OCID(s) OKE uses to provision OCI Load Balancers for LoadBalancer-type Services."
  type        = list(string)
}

variable "node_pool_name" {
  type    = string
  default = "default-node-pool"
}

variable "node_shape" {
  description = "Compute shape for worker nodes, e.g. VM.Standard.E4.Flex."
  type        = string
}

variable "node_shape_config" {
  description = "OCPU/memory config - only applicable (and only rendered) for Flex shapes."
  type = object({
    ocpus         = number
    memory_in_gbs = number
  })
  default = null
}

variable "node_image_id" {
  description = "Optional: OCID of a specific image to use for worker nodes. Leave null to auto-resolve the latest compatible OKE-published image for the cluster's Kubernetes version and shape architecture (recommended)."
  type        = string
  default     = null
}

variable "node_image_name_regex" {
  description = <<-EOT
    Regex used to filter OKE-published node images returned by the
    oci_containerengine_node_pool_option data source when node_image_id
    is not explicitly set. Defaults to Oracle Linux 8, which excludes
    GPU and Ampere/ARM (aarch64) variants - appropriate for AMD64 Flex
    shapes like VM.Standard.E4.Flex/E5.Flex. Change to "Oracle-Linux-9"
    if you want OL9, or add "aarch64" if using an Ampere (A1/A2) shape.
  EOT
  type    = string
  default = "^Oracle-Linux-8\\..*OKE"
}

variable "ssh_public_key" {
  description = "SSH public key injected into worker nodes."
  type        = string
}

variable "node_pool_size" {
  description = "Number of worker nodes per availability domain placement config."
  type        = number
  default     = 1
}

variable "placement_ads" {
  description = <<-EOT
    List of {availability_domain, subnet_id} pairs - one entry per AD
    you want nodes placed in. A dynamic block turns each entry into
    a placement_configs {} block, so the module scales from 1 AD to 3
    without any code change.
  EOT
  type = list(object({
    availability_domain = string
    subnet_id            = string
  }))
}

variable "node_eviction_grace_duration" {
  description = "ISO8601 duration OKE waits before force-evicting pods on node drain."
  type        = string
  default     = "PT30M"
}

variable "freeform_tags" {
  type    = map(string)
  default = {}
}
