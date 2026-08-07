variable "region" {
  description = "OCI region, e.g. eu-jeddah-1"
  type        = string
  default     = "me-jeddah-1"
}

variable "compartment_ocid" {
  description = ""
  type        = string
}

variable "ssh_public_key_path" {
  description = ""
  type        = string
  default     = "C:/OCI/ssh-key-2026-08-06.key.pub"
}

variable "vcn_cidr_block" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "instance_shape" {
  description = "Compute shape for the instance"
  type        = string
  default     = "VM.Standard.E5.Flex"
}

variable "instance_ocpus" {
  description = "Number of OCPUs (for flex shapes)"
  type        = number
  default     = 1
}

variable "instance_memory_in_gbs" {
  description = "Amount of memory in GB (for flex shapes)"
  type        = number
  default     = 12
}

variable "block_volume_size_in_gbs" {
  description = "Size of the block volume in GB"
  type        = number
  default     = 50
}
