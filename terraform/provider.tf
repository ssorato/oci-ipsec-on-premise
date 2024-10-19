terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }

    oci = {
      source  = "oracle/oci"
      version = "~> 6.13.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "oci" {
  tenancy_ocid     = var.oci_tenancy_ocid
  user_ocid        = var.oci_user_ocid
  fingerprint      = var.oci_key_fingerprint
  private_key_path = var.oci_private_key_path
  region           = var.oci_region
}
