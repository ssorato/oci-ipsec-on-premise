resource "oci_core_vcn" "vpn_vcn" {
  compartment_id = data.oci_identity_compartment.vpn_compartment.id
  cidr_blocks    = var.oci_vcn_cidr
  display_name   = format("%s-vcn-%s", data.oci_identity_compartment.vpn_compartment.name, var.common_sufix)
  freeform_tags  = var.common_tags
}

resource "oci_core_drg" "vpn_drg" {
  compartment_id = data.oci_identity_compartment.vpn_compartment.id
  display_name   = format("%s-drg-%s", data.oci_identity_compartment.vpn_compartment.name, var.common_sufix)
  freeform_tags  = var.common_tags
}

resource "oci_core_drg_attachment" "vpn_drg_attachment" {
  drg_id       = oci_core_drg.vpn_drg.id
  display_name = format("%s-drg-attachment-%s", data.oci_identity_compartment.vpn_compartment.name, var.common_sufix)
  network_details {
    id   = oci_core_vcn.vpn_vcn.id
    type = "VCN"
  }
  freeform_tags = var.common_tags
}

resource "oci_core_route_table" "vpn_route_table" {
  compartment_id = data.oci_identity_compartment.vpn_compartment.id
  vcn_id         = oci_core_vcn.vpn_vcn.id
  display_name   = format("%s-route-table-%s", data.oci_identity_compartment.vpn_compartment.name, var.common_sufix)
  freeform_tags  = var.common_tags
  route_rules {
    network_entity_id = oci_core_drg.vpn_drg.id
    destination       = var.azure_subnet_cidr
    destination_type  = "CIDR_BLOCK"
    description       = format("%s-route-drg-rule-%s", data.oci_identity_compartment.vpn_compartment.name, var.common_sufix)
  }
}

resource "oci_core_security_list" "vcn_security_list" {
  compartment_id = data.oci_identity_compartment.vpn_compartment.id
  vcn_id         = oci_core_vcn.vpn_vcn.id
  display_name   = format("%s-seclist-%s", data.oci_identity_compartment.vpn_compartment.name, var.common_sufix)

  egress_security_rules {
    destination = var.azure_subnet_cidr
    protocol    = "all"
  }

  egress_security_rules {
    destination = format("%s/32", azurerm_public_ip.vm_public_ip.ip_address)
    protocol    = "all"
  }

  ingress_security_rules {
    source   = var.azure_subnet_cidr
    protocol = 6
    tcp_options {
      max = 22
      min = 22
    }
  }

  ingress_security_rules {
    source   = var.azure_subnet_cidr
    protocol = 1
  }

  # UDP port 500 and 4500 for the Internet Key Exchange (IKE) protocol
  # Protocol 50 for Encapsulated Security Payload (ESP) IPsec packets
  ingress_security_rules {
    source   = format("%s/32", azurerm_public_ip.vm_public_ip.ip_address)
    protocol = 17
    udp_options {
      max = 4500
      min = 4500
    }
  }

  ingress_security_rules {
    source   = format("%s/32", azurerm_public_ip.vm_public_ip.ip_address)
    protocol = 17
    udp_options {
      max = 500
      min = 500
    }
  }

  ingress_security_rules {
    source   = format("%s/32", azurerm_public_ip.vm_public_ip.ip_address)
    protocol = 50
  }

  freeform_tags = var.common_tags
}

# Use DNS hostnames in this Subnet ?? select !!
resource "oci_core_subnet" "vpn_subnet" {
  cidr_block                 = var.oci_subnet_cidr
  compartment_id             = data.oci_identity_compartment.vpn_compartment.id
  vcn_id                     = oci_core_vcn.vpn_vcn.id
  display_name               = format("%s-subnet-%s", data.oci_identity_compartment.vpn_compartment.name, var.common_sufix)
  route_table_id             = oci_core_route_table.vpn_route_table.id
  security_list_ids          = [oci_core_security_list.vcn_security_list.id]
  prohibit_public_ip_on_vnic = true
  freeform_tags              = var.common_tags
}
