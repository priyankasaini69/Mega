resource "tls_private_key" "example" {
  count     = var.numberofvirtualmachine
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the SSH private key to separate files for each VM
resource "local_file" "private_key_pem" {
  count    = var.numberofvirtualmachine
  content  = tls_private_key.example[count.index].private_key_pem
  filename = "C:/Users/HP/Downloads/dockeri/cicd/mega/Jenkins-MASTER-terraform/3-count-in-terraform/private_key_${count.index + 1}.pem"  # Specify different local paths for each key
}


resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.resource_group_location
}
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}
resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_network_interface" "example" {
  name                = "example-nic-${count.index +1}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  count = var.numberofvirtualmachine

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example[count.index].id
  }
}
resource "azurerm_network_security_group" "example" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = [
    "22",             # SSH
    "80",             # HTTP
    "443",            # HTTPS
    "30000-32767",    # Kubernetes node ports
    "465",            # SMTPS
    "3000-6378",      # Applications (before Redis port)
    "6380-6442",     # Applications (after Redis port)
    "6444-10000",     # Applications (after Redis port)
    "6379",           # Redis
    "25",             # SMTP
    "6443"            # Kubernetes API Server
  ]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_public_ip" "example" {
  name                = "acceptanceTestPublicIp1-${count.index + 1}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
  count               = var.numberofvirtualmachine
}
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example[count.index].id
  network_security_group_id = azurerm_network_security_group.example.id
  count                     = var.numberofvirtualmachine
}
resource "azurerm_linux_virtual_machine" "example" {
  name                            = "example-machine-${count.index + 1}"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = azurerm_resource_group.example.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "adminuser"
  admin_password                  = "Windows@123456"
  disable_password_authentication = false
  count                           = var.numberofvirtualmachine
  network_interface_ids = [
    azurerm_network_interface.example[count.index].id,
  ]

  os_disk {
    name                 = "osdisk-${count.index + 1}"
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
    username   = "adminuser"
    public_key = tls_private_key.example[count.index].public_key_openssh  # Assign a unique public key for each VM
  }
}
