terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-demo"
    storage_account_name = "tfdemostorage123"
    container_name       = "tfstate"
    key                  = "demo.tfstate"
  }
}

provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-demo"
    storage_account_name = "tfdemostorage123"
    container_name       = "tfstate"
    key                  = "demo.tfstate"
  }
}

resource "azurerm_resource_group" "name" {
  name     = var.resource_group_name
  location = var.location_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.name.location
  resource_group_name = azurerm_resource_group.name.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.name.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  resource_group_name = azurerm_resource_group.name.name
  location            = azurerm_resource_group.name.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = var.network_interface_name
  resource_group_name = azurerm_resource_group.name.name
  location            = azurerm_resource_group.name.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.virtual_machine_name
  resource_group_name = azurerm_resource_group.name.name
  location            = azurerm_resource_group.name.location
  size                = "Standard_B1s"

  admin_username = "azadmin"
  admin_password = "Az@12345678"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18_04-lts"
    version   = "latest"
  }
}