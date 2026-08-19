############################################
# modules/subnet/variables.tf
# Every value the module needs comes in from
# the caller (root module) - nothing is hardcoded.
############################################

variable "compartment_id" {
  description = "OCID of the compartment where the subnet resources are created."
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN the subnet belongs to."
  type        = string
}

variable "subnet_name" {
  description = "Display name for the subnet (e.g. 'oke-nodes-subnet')."
  type        = string
}

variable "dns_label" {
  description = "DNS label for the subnet. Must be unique within the VCN."
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the subnet, e.g. 10.0.1.0/24."
  type        = string
}

variable "is_private" {
  description = "Whether this is a private subnet (true) or public subnet (false). Drives prohibit_public_ip_on_vnic."
  type        = bool
  default     = true
}

# ---- Route Table -------------------------------------------------
variable "route_rules" {
  description = <<-EOT
    List of route rules for this subnet's route table.
    Example:
    [
      { destination = "0.0.0.0/0", destination_type = "CIDR_BLOCK", network_entity_id = "<nat_gateway_ocid>" },
      { destination = "all-<region>-services-in-oracle-services-network", destination_type = "SERVICE_CIDR_BLOCK", network_entity_id = "<service_gateway_ocid>" }
    ]
  EOT
  type = list(object({
    destination       = string
    destination_type  = string
    network_entity_id = string
  }))
  default = []
}

# ---- Security List -------------------------------------------------
variable "ingress_rules" {
  description = "List of ingress security rules to attach to this subnet's security list."
  type = list(object({
    protocol    = string           # "6" = TCP, "17" = UDP, "1" = ICMP, "all"
    source      = string
    source_type = optional(string, "CIDR_BLOCK")
    description = optional(string, "")
    stateless   = optional(bool, false)
    tcp_options = optional(object({
      min = number
      max = number
    }), null)
    udp_options = optional(object({
      min = number
      max = number
    }), null)
    icmp_options = optional(object({
      type = number
      code = optional(number, null)
    }), null)
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress security rules to attach to this subnet's security list."
  type = list(object({
    protocol         = string
    destination      = string
    destination_type = optional(string, "CIDR_BLOCK")
    description      = optional(string, "")
    stateless        = optional(bool, false)
  }))
  default = [
    {
      protocol         = "all"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      description      = "Default allow-all egress"
      stateless        = false
    }
  ]
}

# ---- Flow logs (conditional resource) -----------------------------
variable "enable_flow_logs" {
  description = "Whether to enable VCN flow logs on this subnet. Controls whether the log resource is created at all."
  type        = bool
  default     = false
}

variable "log_group_id" {
  description = "OCID of the OCI Logging log group to store the flow log in. Required only when enable_flow_logs = true."
  type        = string
  default     = null
}

variable "flow_log_retention_days" {
  description = "Retention period (days) for the flow log, if enabled."
  type        = number
  default     = 30
}

variable "freeform_tags" {
  description = "Freeform tags applied to every resource created by this module."
  type        = map(string)
  default     = {}
}
