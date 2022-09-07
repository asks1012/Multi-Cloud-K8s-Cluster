resource "null_resource"  "depends_on_master" {
  depends_on = [
    null_resource.master_ip
  ]
}

resource "azurerm_resource_group" "terr_azure_rg" {
  name     = "terr_rg"
  location = var.location
}

resource "azurerm_virtual_network" "terr_azure_vn" {
  name                = "terr_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.terr_azure_rg.location
  resource_group_name = azurerm_resource_group.terr_azure_rg.name
}

resource "azurerm_subnet" "terr_azure_subnet" {
  name                 = "terr_subnet"
  resource_group_name  = azurerm_resource_group.terr_azure_rg.name
  virtual_network_name = azurerm_virtual_network.terr_azure_vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "terr_azure_sg" {
  name                = "azure_sg"
  location            = azurerm_resource_group.terr_azure_rg.location
  resource_group_name = azurerm_resource_group.terr_azure_rg.name

  security_rule {
    name                       = "allow_all_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_all_outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "terr_azure_sgAssoc" {
  subnet_id                 = azurerm_subnet.terr_azure_subnet.id
  network_security_group_id = azurerm_network_security_group.terr_azure_sg.id
}

resource "azurerm_public_ip" "terr_azure_ip" {
  name                = "terr_ip"
  resource_group_name = azurerm_resource_group.terr_azure_rg.name
  location            = azurerm_resource_group.terr_azure_rg.location
  allocation_method   = "Static"
  ip_version          = "IPv4"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "terr_azure_ni" {
  name                = "terr_ni"
  location            = azurerm_resource_group.terr_azure_rg.location
  resource_group_name = azurerm_resource_group.terr_azure_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terr_azure_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.terr_azure_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "terr_azure_vm" {
  name                  = "terr-vm"
  resource_group_name   = azurerm_resource_group.terr_azure_rg.name
  location              = azurerm_resource_group.terr_azure_rg.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.terr_azure_ni.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.azure_public_key)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "null_resource"  "slave_ip1" {
  provisioner "local-exec" {
    command = "echo \"${azurerm_linux_virtual_machine.terr_azure_vm.public_ip_address} ansible_ssh_private_key_file=${var.azure_private_key} ansible_ssh_user=${var.admin_username}\n\" >> ../inventory.txt"
  }
}