# Generate an SSH key
resource "tls_private_key" "example1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the SSH private key to a file in .pem format
resource "local_file" "private_key_pem" {
  content  = tls_private_key.example1.private_key_pem
  filename = "C:/Users/HP/Downloads/dockeri/cicd/mega/Jenkins-Worker-terraform/private_key.pem"  # Specify the local path for the SSH private key
}



resource "azurerm_resource_group" "example1" {
  name     = var.resource_group_name
  location = var.resource_group_location
}
resource "azurerm_virtual_network" "example1" {
  name                = "example1-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example1.location
  resource_group_name = azurerm_resource_group.example1.name
}
resource "azurerm_subnet" "example1" {
  name                 = "internal1"
  resource_group_name  = azurerm_resource_group.example1.name
  virtual_network_name = azurerm_virtual_network.example1.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_network_interface" "example1" {
  name                = "example1-nic1"
  location            = azurerm_resource_group.example1.location
  resource_group_name = azurerm_resource_group.example1.name

  ip_configuration {
    name                          = "internal1"
    subnet_id                     = azurerm_subnet.example1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example1.id
  }
}
resource "azurerm_network_security_group" "example1" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.example1.location
  resource_group_name = azurerm_resource_group.example1.name

  security_rule {
  name                       = "test123"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_ranges    = [443, 80, 22]
  source_address_prefix      = "*"
  destination_address_prefix = "*"
}

}
resource "azurerm_public_ip" "example1" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.example1.name
  location            = azurerm_resource_group.example1.location
  allocation_method   = "Static"
}
resource "azurerm_network_interface_security_group_association" "example1" {
  network_interface_id      = azurerm_network_interface.example1.id
  network_security_group_id = azurerm_network_security_group.example1.id
}
resource "azurerm_linux_virtual_machine" "example1" {
  name                            = "example1-machine1"
  resource_group_name             = azurerm_resource_group.example1.name
  location                        = azurerm_resource_group.example1.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "jenkins-worker"
  admin_password                  = "Windows@123456"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.example1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  admin_ssh_key {
    username   = "jenkins-worker"
    public_key = tls_private_key.example1.public_key_openssh
  }
}
