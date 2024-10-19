resource "oci_core_cpe" "vpn_cpe" {
  compartment_id      = data.oci_identity_compartment.vpn_compartment.id
  ip_address          = azurerm_public_ip.vm_public_ip.ip_address
  cpe_device_shape_id = "3842bd0b-7cdf-4c72-8042-be13aac998bf" # Libreswan - oci network cpe-device-shape list
  display_name        = format("%s-cpe-%s", data.oci_identity_compartment.vpn_compartment.name, var.common_sufix)
  freeform_tags       = var.common_tags
  is_private          = false
}

resource "oci_core_ipsec" "vpn_ipsec_connection" {
  compartment_id            = data.oci_identity_compartment.vpn_compartment.id
  cpe_id                    = oci_core_cpe.vpn_cpe.id
  cpe_local_identifier      = azurerm_public_ip.vm_public_ip.ip_address
  cpe_local_identifier_type = "IP_ADDRESS"
  display_name              = format("%s-ipsec-%s", data.oci_identity_compartment.vpn_compartment.name, var.common_sufix)
  drg_id                    = oci_core_drg.vpn_drg.id
  freeform_tags             = var.common_tags
  static_routes = [
    var.azure_subnet_cidr,
  ]
}

# Site-to-Site VPN has two redundant IPSec tunnels
data "oci_core_ipsec_connection_tunnels" "vpn_ipsec_connection_tunnels" {
  ipsec_id = oci_core_ipsec.vpn_ipsec_connection.id
}

resource "oci_core_ipsec_connection_tunnel_management" "vpn_ipsec_connection_tunnel_1" {
  ipsec_id                = oci_core_ipsec.vpn_ipsec_connection.id
  tunnel_id               = data.oci_core_ipsec_connection_tunnels.vpn_ipsec_connection_tunnels.ip_sec_connection_tunnels[0].id
  display_name            = format("%s-ipsec-tunel%s-%s", data.oci_identity_compartment.vpn_compartment.name, 1, var.common_sufix)
  shared_secret           = var.ipsec_shared_secret
  ike_version             = "V2"
  routing                 = "STATIC"
  nat_translation_enabled = "AUTO"
  oracle_can_initiate     = "INITIATOR_OR_RESPONDER"
  phase_one_details {
    is_custom_phase_one_config      = true
    custom_authentication_algorithm = var.ipsec.phase_one_authentication_algorithm
    custom_dh_group                 = var.ipsec.phase_one_dh_group
    custom_encryption_algorithm     = var.ipsec.phase_one_encryption_algorithm
    lifetime                        = var.ipsec.phase_one_lifetime
  }
  phase_two_details {
    is_custom_phase_two_config      = true
    custom_authentication_algorithm = var.ipsec.phase_two_authentication_algorithm
    dh_group                        = var.ipsec.phase_two_dh_group
    custom_encryption_algorithm     = var.ipsec.phase_two_encryption_algorithm
    lifetime                        = var.ipsec.phase_two_lifetime
    is_pfs_enabled                  = var.ipsec.phase_two_pfs_enabled
  }
  # lifecycle {
  #   ignore_changes = [
  #     time_status_updated
  #   ]
  # }
}

resource "oci_core_ipsec_connection_tunnel_management" "vpn_ipsec_connection_tunnel_2" {
  ipsec_id                = oci_core_ipsec.vpn_ipsec_connection.id
  tunnel_id               = data.oci_core_ipsec_connection_tunnels.vpn_ipsec_connection_tunnels.ip_sec_connection_tunnels[1].id
  display_name            = format("%s-ipsec-tunel%s-%s", data.oci_identity_compartment.vpn_compartment.name, 2, var.common_sufix)
  shared_secret           = var.ipsec_shared_secret
  ike_version             = "V2"
  routing                 = "STATIC"
  nat_translation_enabled = "AUTO"
  oracle_can_initiate     = "INITIATOR_OR_RESPONDER"
  phase_one_details {
    is_custom_phase_one_config      = true
    custom_authentication_algorithm = var.ipsec.phase_one_authentication_algorithm
    custom_dh_group                 = var.ipsec.phase_one_dh_group
    custom_encryption_algorithm     = var.ipsec.phase_one_encryption_algorithm
    lifetime                        = var.ipsec.phase_one_lifetime
  }
  phase_two_details {
    is_custom_phase_two_config      = true
    custom_authentication_algorithm = var.ipsec.phase_two_authentication_algorithm
    dh_group                        = var.ipsec.phase_two_dh_group
    custom_encryption_algorithm     = var.ipsec.phase_two_encryption_algorithm
    lifetime                        = var.ipsec.phase_two_lifetime
    is_pfs_enabled                  = var.ipsec.phase_two_pfs_enabled
  }
  # lifecycle {
  #   ignore_changes = [
  #     time_status_updated
  #   ]
  # }
}