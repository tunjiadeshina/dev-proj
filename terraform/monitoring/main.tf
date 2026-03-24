
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatedevops"
    container_name       = "tfstate"
    key                  = "monitoring.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "monitoring_rg" {
  name     = "monitoring-rg"
  location = var.location
}

resource "azurerm_virtual_network" "monitoring_vnet" {
  name                = "monitoring-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.monitoring_rg.name
}

resource "azurerm_subnet" "monitoring_subnet" {
  name                 = "monitoring-subnet"
  resource_group_name  = azurerm_resource_group.monitoring_rg.name
  virtual_network_name = azurerm_virtual_network.monitoring_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "monitoring_ip" {
  name                = "monitoring-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "monitoring_nsg" {
  name                = "monitoring-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.monitoring_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_allowed_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Prometheus"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "10.3.1.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Grafana"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "10.3.1.0/24"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "monitoring_nic" {
  name                = "monitoring-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.monitoring_rg.name

  ip_configuration {
    name                          = "monitoring-nic-config"
    subnet_id                     = azurerm_subnet.monitoring_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.monitoring_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "monitoring_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.monitoring_nic.id
  network_security_group_id = azurerm_network_security_group.monitoring_nsg.id
}

resource "azurerm_linux_virtual_machine" "monitoring_vm" {
  name                = "monitoring-vm"
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  location            = var.location
  size                = "Standard_D2s_v3"
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.monitoring_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = trimspace(var.ssh_public_key)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}