terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "oci" {
  config_file_profile = "DEFAULT"
  region               = var.region
}
