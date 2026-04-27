resource "azurerm_resource_group" "nebo-app-rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "nebo-app-vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.nebo-app-rg.location
  resource_group_name = azurerm_resource_group.nebo-app-rg.name
  address_space       = [var.vnet_address_space]
}

resource "azurerm_subnet" "public-subnet" {
  name                 = "${var.vnet_name}-public-subnet"
  resource_group_name  = azurerm_resource_group.nebo-app-rg.name
  virtual_network_name = azurerm_virtual_network.nebo-app-vnet.name
  address_prefixes     = [var.public_subnet_address_prefix]
}

resource "azurerm_subnet" "private-subnet" {
  name                 = "${var.vnet_name}-private-subnet"
  resource_group_name  = azurerm_resource_group.nebo-app-rg.name
  virtual_network_name = azurerm_virtual_network.nebo-app-vnet.name
  address_prefixes     = [var.private_subnet_address_prefix]
}

resource "azurerm_public_ip" "nebo-app-public-ip" {
  name                = "${var.frontend_vm_name}-public-ip"
  location            = azurerm_resource_group.nebo-app-rg.location
  resource_group_name = azurerm_resource_group.nebo-app-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "nebo-app-public-nsg" {
  name                = "${var.vnet_name}-public-nsg"
  location            = azurerm_resource_group.nebo-app-rg.location
  resource_group_name = azurerm_resource_group.nebo-app-rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nebo-app-public-nic-nsg-association" {
  network_interface_id      = azurerm_network_interface.nebo-app-frontend-nic.id
  network_security_group_id = azurerm_network_security_group.nebo-app-public-nsg.id
}

resource "azurerm_network_security_group" "nebo-app-backend-nsg" {
  name                = "${var.vnet_name}-private-nsg"
  location            = azurerm_resource_group.nebo-app-rg.location
  resource_group_name = azurerm_resource_group.nebo-app-rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "nebo-app-backend-nic-nsg-association" {
  network_interface_id      = azurerm_network_interface.nebo-app-backend-nic.id
  network_security_group_id = azurerm_network_security_group.nebo-app-backend-nsg.id
}


resource "azurerm_network_security_group" "nebo-app-database-nsg" {
  name                = "${var.vnet_name}-database-nsg"
  location            = azurerm_resource_group.nebo-app-rg.location
  resource_group_name = azurerm_resource_group.nebo-app-rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-MySQL"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "nebo-app-database-nic-nsg-association" {
  network_interface_id      = azurerm_network_interface.nebo-app-database-nic.id
  network_security_group_id = azurerm_network_security_group.nebo-app-database-nsg.id
}