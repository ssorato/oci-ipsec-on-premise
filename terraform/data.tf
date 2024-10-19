data "http" "myip" {
  url = "http://ifconfig.me"
}

data "oci_identity_compartment" "vpn_compartment" {
  id = var.oci_compartment_ocid
}
