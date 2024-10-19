data "oci_identity_availability_domains" "ads" {
  compartment_id = var.oci_tenancy_ocid
}

resource "oci_core_instance" "vm" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = data.oci_identity_compartment.vpn_compartment.id
  display_name        = format("vm-ipsec-%s", var.common_sufix)
  shape               = "VM.Standard.E2.1.Micro"
  shape_config {
    memory_in_gbs = 1
    ocpus         = 1
  }
  source_details {
    source_id   = "ocid1.image.oc1.iad.aaaaaaaal5ocygrbx2lfvrnugr6yqlskpomeww6d7pqb3zes2pzho3td4gcq" # Oracle-Linux-8.10-2024.09.30-0
    source_type = "image"
  }
  create_vnic_details {
    assign_public_ip = false
    subnet_id        = oci_core_subnet.vpn_subnet.id
  }
  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
  }
  preserve_boot_volume = false

  freeform_tags = var.common_tags
}