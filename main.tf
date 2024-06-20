data "azurerm_resource_group" "azuredevops" {
  name = "azuredevops"
}

data "azurerm_subnet" "default" {
  name                 = "default"
  virtual_network_name = "vmagent-vnet"
  resource_group_name  = data.azurerm_resource_group.azuredevops.name
}

data "azurerm_virtual_network" "agentvm-vnet" {
  name                = "vmagent-vnet"
  resource_group_name = data.azurerm_resource_group.azuredevops.name

}

resource "azurerm_public_ip" "public_ip" {
  name                = "agentvm-ip"
  resource_group_name = data.azurerm_resource_group.azuredevops.name
  location            = var.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "agentvm_nic" {
  name                = "agentvm_nic"
  resource_group_name = data.azurerm_resource_group.azuredevops.name
  location            = var.location

  ip_configuration {
    name                          = "Internal"
    subnet_id                     = data.azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id

  }

}

resource "azurerm_network_security_group" "nsg" {
  name                = "ssh_nsg"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.azuredevops.name

  security_rule {
    name                       = "allow_ssh_sg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"

  }
  security_rule {
    name                       = "allow_http_sg"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_https_sg"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.agentvm_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_linux_virtual_machine" "main" {
  name                = var.agent_vm_name
  resource_group_name = data.azurerm_resource_group.azuredevops.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username 
  network_interface_ids = [azurerm_network_interface.agentvm_nic.id]
  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
data "azurerm_public_ip" "public_ip" {
  name                = azurerm_public_ip.public_ip.name
  resource_group_name = data.azurerm_resource_group.azuredevops.name
  depends_on          = [azurerm_linux_virtual_machine.main]
}

output "ip_address" {
  value = data.azurerm_public_ip.public_ip.ip_address
}

## Install Docker and Configure Self-Hosted Agent
resource "null_resource" "install_docker" {
  provisioner "remote-exec" {
    inline = ["${file("\\script.sh")}"]
    
    connection {
      type     = "ssh"
      user     = azurerm_linux_virtual_machine.main.admin_username
      password = azurerm_linux_virtual_machine.main.admin_password
      host     = data.azurerm_public_ip.public_ip.ip_address
      timeout  = "10m"
    }
  }
}