############################################
# environments/dev/providers.tf
############################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }

  # Optional: use a backend for team state sharing, e.g. OCI Object Storage (S3-compatible)
  # backend "s3" {
  #   bucket   = "terraform-state-bucket"
  #   key      = "week3/oke/terraform.tfstate"
  #   region   = "us-ashburn-1"
  #   endpoint = "https://<namespace>.compat.objectstorage.us-ashburn-1.oraclecloud.com"
  #   skip_region_validation      = true
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true
  #   force_path_style            = true
  # }
}

provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
