variable "region" { type = string }
variable "tenancy_ocid" { type = string }
variable "user_ocid" { type = string }
variable "fingerprint" { type = string }
variable "private_key_path" { type = string }

variable "compartment_id" { type = string }
variable "vcn_cidr" { type = string }

variable "environment" {
  description = "Environment name, used as a prefix/tag (dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "availability_domains" {
  description = "List of AD names to spread node pool placement across."
  type        = list(string)
}

variable "ssh_public_key" {
  type = string
}

variable "node_image_id" {
  description = "Optional: pin a specific worker node image OCID. Leave unset (null) to auto-resolve the latest compatible OKE-published Oracle Linux 8 (AMD64) image for the target Kubernetes version - see modules/oke."
  type        = string
  default     = null
}

variable "kubernetes_version" {
  type    = string
  default = "v1.29.1"
}
# log_group_id removed - the log group is now created in network.tf
