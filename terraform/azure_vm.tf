locals {
  inbound_access = [
    {
      name                   = "internal-ssh"
      source_address_prefix  = "VirtualNetwork"
      protocol               = "Tcp"
      destination_port_range = "22"
      priority               = 100
    },
    {
      name                   = "external-ssh-from-my-ip"
      source_address_prefix  = "${chomp(data.http.myip.response_body)}/32"
      protocol               = "Tcp"
      destination_port_range = "22"
      priority               = 101
    },
    {
      name                   = "external-ipsec-500-tunel1"
      source_address_prefix  = format("%s/32", data.oci_core_ipsec_connection_tunnels.vpn_ipsec_connection_tunnels.ip_sec_connection_tunnels[0].vpn_ip)
      protocol               = "Udp"
      destination_port_range = "500"
      priority               = 102
    },
    {
      name                   = "external-ipsec-4500-tunel1"
      source_address_prefix  = format("%s/32", data.oci_core_ipsec_connection_tunnels.vpn_ipsec_connection_tunnels.ip_sec_connection_tunnels[0].vpn_ip)
      protocol               = "Udp"
      destination_port_range = "4500"
      priority               = 103
    },
    {
      name                   = "external-ipsec-esp-tunel1"
      source_address_prefix  = format("%s/32", data.oci_core_ipsec_connection_tunnels.vpn_ipsec_connection_tunnels.ip_sec_connection_tunnels[0].vpn_ip)
      protocol               = "Esp"
      destination_port_range = "*"
      priority               = 104
    },
    {
      name                   = "external-ipsec-500-tunel2"
      source_address_prefix  = format("%s/32", data.oci_core_ipsec_connection_tunnels.vpn_ipsec_connection_tunnels.ip_sec_connection_tunnels[1].vpn_ip)
      protocol               = "Udp"
      destination_port_range = "500"
      priority               = 105
    },
    {
      name                   = "external-ipsec-4500-tunel2"
      source_address_prefix  = format("%s/32", data.oci_core_ipsec_connection_tunnels.vpn_ipsec_connection_tunnels.ip_sec_connection_tunnels[1].vpn_ip)
      protocol               = "Udp"
      destination_port_range = "4500"
      priority               = 106
    },
    {
      name                   = "external-ipsec-esp-tunel2"
      source_address_prefix  = format("%s/32", data.oci_core_ipsec_connection_tunnels.vpn_ipsec_connection_tunnels.ip_sec_connection_tunnels[1].vpn_ip)
      protocol               = "Esp"
      destination_port_range = "*"
      priority               = 107
    },
    {
      name                   = "external-remote-ssh"
      source_address_prefix  = var.oci_subnet_cidr
      protocol               = "Tcp"
      destination_port_range = "22"
      priority               = 108
    },
    {
      name                   = "external-remote-icmp"
      source_address_prefix  = var.oci_subnet_cidr
      protocol               = "Icmp"
      destination_port_range = "*"
      priority               = 109
    },
    {
      name                   = "internal-icmp-to-public-ip"
      source_address_prefix  = format("%s/32", azurerm_network_interface.vm_nic.private_ip_address)
      protocol               = "Icmp"
      destination_port_range = "*"
      priority               = 110
    }
  ]
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = format("nsg-%s", var.common_sufix)
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name

  dynamic "security_rule" {
    for_each = local.inbound_access
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = security_rule.value.protocol
      source_port_range          = "*"
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = "VirtualNetwork"
    }
  }

  tags = merge(
    {
      name = "nsg-vmpoc"
    },
    var.common_tags
  )

  depends_on = [
    oci_core_ipsec_connection_tunnel_management.vpn_ipsec_connection_tunnel_1,
    oci_core_ipsec_connection_tunnel_management.vpn_ipsec_connection_tunnel_2
  ]
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = format("public-ip-%s", var.common_sufix)
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
  allocation_method   = "Static"
  sku                 = "Basic"
  zones               = []
  tags = merge(
    {
      name = format("public-ip-%s", var.common_sufix)
    },
    var.common_tags
  )
}

resource "azurerm_network_interface" "vm_nic" {
  name                = format("nic-%s", var.common_sufix)
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name

  ip_configuration {
    name                          = format("nic-config-%s", var.common_sufix)
    subnet_id                     = azurerm_subnet.azure_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }

  tags = merge(
    {
      name = format("nic-%s", var.common_sufix)
    },
    var.common_tags
  )
}

resource "azurerm_network_interface_security_group_association" "vm_nic_nsg" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = format("vm-%s", var.common_sufix)
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id
  ]
  size = "Standard_B1ms"

  os_disk {
    name                 = "osdisk-vmpoc"
    caching              = "ReadOnly"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Oracle"
    offer     = "Oracle-Linux"
    sku       = "ol94-lvm-gen2"
    version   = "latest"
  }

  computer_name                   = format("vm-%s", var.common_sufix)
  admin_username                  = "sandbox"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "sandbox"
    public_key = file(var.ssh_public_key_file)
  }

  tags = merge(
    {
      name = format("vm-%s", var.common_sufix)
    },
    var.common_tags
  )
}
