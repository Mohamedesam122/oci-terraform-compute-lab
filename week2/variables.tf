############################################
# Provider / Auth
############################################
variable "tenancy_ocid" {
  description = "OCID of the tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the user calling the API"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the API signing key"
  type        = string
}

variable "private_key_path" {
  description = "Local path to the API signing private key"
  type        = string
}

variable "region" {
  description = "OCI region"
  type        = string
}

variable "compartment_id" {
  description = "OCID of the compartment where all resources are created"
  type        = string
}

############################################
# Naming
############################################
variable "project_name" {
  description = "Short project/lab name used as a prefix for all resource names"
  type        = string
  default     = "week2-lab"
}

############################################
# Networking
############################################
variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "dns_label" {
  description = "DNS label for the VCN"
  type        = string
  default     = "vcnweek2"
}

############################################
# Compute
############################################
variable "availability_domain" {
  description = "Availability domain name (e.g. as returned by the AD data source), leave null to auto-pick the first AD"
  type        = string
  default     = null
}

variable "instance_shape" {
  description = "Shape of the compute instance"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "instance_ocpus" {
  description = "Number of OCPUs for the flexible shape"
  type        = number
  default     = 1
}

variable "instance_memory_in_gbs" {
  description = "Amount of memory (GB) for the flexible shape"
  type        = number
  default     = 8
}

variable "ssh_public_key_path" {
  description = "Local path to the SSH public key to inject into the instance"
  type        = string
}

variable "app_port" {
  description = "TCP port the application listens on inside the private instance"
  type        = number
  default     = 8080
}

############################################
# Load Balancer
############################################
variable "lb_min_bandwidth_mbps" {
  description = "Minimum bandwidth (Mbps) for the flexible load balancer shape"
  type        = number
  default     = 10
}

variable "lb_max_bandwidth_mbps" {
  description = "Maximum bandwidth (Mbps) for the flexible load balancer shape"
  type        = number
  default     = 10
}

variable "lb_listener_port" {
  description = "Public-facing port on the load balancer listener"
  type        = number
  default     = 80
}

############################################
# File Storage
############################################
variable "fss_export_path" {
  description = "Export path for the File Storage export"
  type        = string
  default     = "/appdata"
}
