variable "common_tags" {
  type        = map(string)
  description = "Common tags"
  default = {
    sandbox    = "sbox-vpn"
    terraform  = "oci-ipsec-on-premise"
    created_by = "terraform-oci-ipsec-on-premise"
  }
}

variable "common_sufix" {
  type        = string
  description = "Common resource sufix"
  default     = "sbox-vpn"
}

variable "oci_tenancy_ocid" {
  type        = string
  description = "Tenancy OCID"
}

variable "oci_user_ocid" {
  type        = string
  description = "User OCID"
}

variable "oci_key_fingerprint" {
  type        = string
  description = "OCI key fingerprint"
}

variable "oci_private_key_path" {
  type        = string
  description = "OCI private key path"
}

variable "oci_region" {
  type        = string
  description = "OCI region"
  default     = "us-ashburn-1"
}

variable "oci_compartment_ocid" {
  type    = string
  description = "The OCI compartment ocid"
}

variable "oci_vcn_cidr" {
  type        = list(string)
  description = "The VCN CIDR"
  default     = ["172.16.0.0/16"]
}

variable "oci_subnet_cidr" {
  type        = string
  description = "The VCN CIDR"
  default     = "172.16.1.0/24"
}

variable "oci_vm_private_ip" {
  type        = string
  description = "The VM private IP"
  default     = "172.16.1.100"
}

variable "ipsec_shared_secret" {
  type        = string
  description = "The IpSec shared secret"
}

variable "ipsec" {
  type = object({
    phase_one_authentication_algorithm = string
    phase_one_dh_group                 = string
    phase_one_encryption_algorithm     = string
    phase_one_lifetime                 = number
    phase_two_authentication_algorithm = string
    phase_two_dh_group                 = string
    phase_two_encryption_algorithm     = string
    phase_two_lifetime                 = number
    phase_two_pfs_enabled              = bool
  })
  description = "IpSec parameters"
  default = {
    phase_one_authentication_algorithm = "SHA2_256"
    phase_one_dh_group                 = "GROUP5"
    phase_one_encryption_algorithm     = "AES_256_CBC"
    phase_one_lifetime                 = 28800
    phase_two_authentication_algorithm = "HMAC_SHA2_256_128"
    phase_two_dh_group                 = "GROUP5"
    phase_two_encryption_algorithm     = "AES_256_CBC"
    phase_two_lifetime                 = 3600
    phase_two_pfs_enabled              = true
  }
}

variable "azure_location" {
  description = "The Azure location"
  default     = "eastus"
}

variable "azure_vnet_cidr" {
  type        = string
  description = "The VCN CIDR"
  default     = "172.17.0.0/16"
}

variable "azure_subnet_cidr" {
  type        = string
  description = "The VCN CIDR"
  default     = "172.17.4.0/22"
}

variable "ssh_private_key_file" {
  type        = string
  description = "The ssh private key for Linux VMs"
  default     = "~/.ssh/id_rsa"
}

variable "ssh_public_key_file" {
  type        = string
  description = "The ssh public key for Linux VMs"
  default     = "~/.ssh/id_rsa.pub"
}


