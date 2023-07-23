terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.65.0"
    }
  }
}

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "vadapav1" {
  name     = "vadapav"
  location = "eastus"
  tags = {
    "env" = "prod1"
    "app" = "cts"
  }
}

resource "azurerm_virtual_network" "vadapav1-net1" {

  name                = "vadapav1-net1"
  resource_group_name = azurerm_resource_group.vadapav1.name
  location            = azurerm_resource_group.vadapav1.location
  address_space       = ["99.99.0.0/24"]
}

resource "azurerm_subnet" "vadapav1-s1" {
  name                = "vadapav1-s1"
  resource_group_name = azurerm_resource_group.vadapav1.name
  # location             = azurerm_resource_group.vadapav1.location
  address_prefixes     = ["99.99.0.0/25"]
  virtual_network_name = azurerm_virtual_network.vadapav1-net1.name

}
resource "azurerm_subnet" "vadapav1-s2" {
  name                = "vadapav1-s2"
  resource_group_name = azurerm_resource_group.vadapav1.name
  # location            = azurerm_resource_group.vadapav1.location
  address_prefixes     = ["99.99.0.128/25"]
  virtual_network_name = azurerm_virtual_network.vadapav1-net1.name
}

resource "azurerm_public_ip" "vadapav1-pip" {
  count               = 1
  name                = "vadapav1-public-ip-${count.index}"
  location            = azurerm_resource_group.vadapav1.location
  resource_group_name = azurerm_resource_group.vadapav1.name
  allocation_method   = "Dynamic"

}

resource "azurerm_network_interface" "vm-nic" {
  count               = 1
  name                = "vm-nic-${count.index}"
  resource_group_name = azurerm_resource_group.vadapav1.name
  location            = azurerm_resource_group.vadapav1.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vadapav1-s1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vadapav1-pip[count.index].id

  }

}
resource "azurerm_linux_virtual_machine" "vm1" {
  count               = 1
  name                = "vm-${count.index}"
  resource_group_name = azurerm_resource_group.vadapav1.name
  location            = azurerm_resource_group.vadapav1.location
  size                = "Standard_B1s"
  admin_username      = "ctsadmin"
  admin_password      = "Aws@12345678"


  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.vm-nic[count.index].id
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
   # publisher = "procomputers"
    #offer     = "RHEL"
    #sku       = "8.7"
    #version   = "latest"
  }
  boot_diagnostics {
    storage_account_uri = ""
  }




}
output "azurerm_public_ip" {
  #resource_group_name = azurerm_resource_group.vadapav1.name
  #location            = azurerm_resource_group.vadapav1.location
  value = azurerm_public_ip.vadapav1-pip[0].id

}
