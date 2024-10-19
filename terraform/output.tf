output "oci_ipsec_tunel1_ip" {
  value = data.oci_core_ipsec_connection_tunnels.vpn_ipsec_connection_tunnels.ip_sec_connection_tunnels[0].vpn_ip
}

output "oci_ipsec_tunel2_ip" {
  value = data.oci_core_ipsec_connection_tunnels.vpn_ipsec_connection_tunnels.ip_sec_connection_tunnels[1].vpn_ip
}

output "oci_vm_private_ip" {
  value = oci_core_instance.vm.private_ip
}

output "azure_vm_private_ip" {
  value = azurerm_network_interface.vm_nic.private_ip_address
}

output "azure_vm_public_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}


resource "local_file" "ansible-inventory" {
  content = templatefile("templates/vm_inventory.tpl",
    {
      admin_username                     = "sandbox"
      ssh_private_key_file               = var.ssh_private_key_file
      name                               = azurerm_linux_virtual_machine.vm.name
      ip                                 = azurerm_public_ip.vm_public_ip.ip_address
      local_private_ip                   = azurerm_network_interface.vm_nic.private_ip_address
      local_public_ip                    = azurerm_public_ip.vm_public_ip.ip_address
      local_subnet                       = var.azure_subnet_cidr
      remote_private_ip                  = oci_core_instance.vm.private_ip
      remote_public_ip_tunel1            = data.oci_core_ipsec_connection_tunnels.vpn_ipsec_connection_tunnels.ip_sec_connection_tunnels[0].vpn_ip
      remote_public_ip_tunel2            = data.oci_core_ipsec_connection_tunnels.vpn_ipsec_connection_tunnels.ip_sec_connection_tunnels[1].vpn_ip
      remote_subnet                      = var.oci_subnet_cidr
      phase_one_authentication_algorithm = var.ipsec.phase_one_authentication_algorithm
      phase_one_dh_group                 = var.ipsec.phase_one_dh_group
      phase_one_encryption_algorithm     = var.ipsec.phase_one_encryption_algorithm
      phase_one_lifetime                 = var.ipsec.phase_one_lifetime
      phase_two_authentication_algorithm = var.ipsec.phase_two_authentication_algorithm
      phase_two_dh_group                 = var.ipsec.phase_two_dh_group
      phase_two_encryption_algorithm     = var.ipsec.phase_two_encryption_algorithm
      phase_two_lifetime                 = var.ipsec.phase_two_lifetime
      phase_two_pfs_enabled              = var.ipsec.phase_two_pfs_enabled
      ipsec_shared_secret                = var.ipsec_shared_secret
    }
  )
  filename             = "../ansible/inventories/tf_${azurerm_linux_virtual_machine.vm.name}.yaml"
  directory_permission = "0755"
  file_permission      = "0644"
}
