locals {
  database_private_ip   = azurerm_network_interface.database-nic.private_ip_address
  backend_private_ip    = azurerm_network_interface.backend-nic.private_ip_address
  database_url          = "mysql+pymysql://${urlencode(var.database_user)}:${urlencode(var.database_password)}@${local.database_private_ip}:3306/${urlencode(var.database_name)}"
  cors_origins          = "http://${azurerm_public_ip.frontend-public-ip.ip_address}"
}

resource "azurerm_linux_virtual_machine" "frontend-vm" {
  name                = var.frontend_vm_name
  resource_group_name = azurerm_resource_group.nebo-app-rg.name
  location            = azurerm_resource_group.nebo-app-rg.location
  size                = var.frontend_vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.frontend-nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.to_public_key_path)
  }

  os_disk {
    caching              = var.caching_type
    storage_account_type = var.storage_account_type
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.image_version
  }

  custom_data = base64encode(templatefile("../scripts/frontend-setup.tftpl", {
    backend_ip = local.backend_private_ip
  }))
}

resource "azurerm_network_interface" "frontend-nic" {
  name                = "${var.frontend_vm_name}-nic"
  location            = azurerm_resource_group.nebo-app-rg.location
  resource_group_name = azurerm_resource_group.nebo-app-rg.name

  ip_configuration {
    name                          = "${var.frontend_vm_name}-ipconfig"
    subnet_id                     = azurerm_subnet.public-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.frontend-public-ip.id
  }
}

resource "azurerm_linux_virtual_machine" "backend-vm" {
  name                = var.backend_vm_name
  resource_group_name = azurerm_resource_group.nebo-app-rg.name
  location            = azurerm_resource_group.nebo-app-rg.location
  size                = var.backend_vm_size
  admin_username      = var.admin_username

  depends_on = [
    azurerm_linux_virtual_machine.database-vm,
  ]

  network_interface_ids = [
    azurerm_network_interface.backend-nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.to_public_key_path)
  }

  os_disk {
    caching              = var.caching_type
    storage_account_type = var.storage_account_type
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.image_version
  }

  custom_data = base64encode(templatefile("../scripts/backend-setup.tftpl", {
    database_url = local.database_url
    cors_origins   = local.cors_origins
  }))
}

resource "azurerm_network_interface" "backend-nic" {
  name                = "${var.backend_vm_name}-nic"
  location            = azurerm_resource_group.nebo-app-rg.location
  resource_group_name = azurerm_resource_group.nebo-app-rg.name

  ip_configuration {
    name                          = "${var.backend_vm_name}-ipconfig"
    subnet_id                     = azurerm_subnet.private-subnet.id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.backend-public-ip.id
  }
}

resource "azurerm_linux_virtual_machine" "database-vm" {
  name                = var.database_vm_name
  resource_group_name = azurerm_resource_group.nebo-app-rg.name
  location            = azurerm_resource_group.nebo-app-rg.location
  size                = var.database_vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.database-nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.to_public_key_path)
  }

  os_disk {
    caching              = var.caching_type
    storage_account_type = var.storage_account_type
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.image_version
  }

  custom_data = base64encode(templatefile("../scripts/database-setup.tftpl", {
    database_name     = var.database_name
    database_user     = var.database_user
    database_password = var.database_password
    init_sql_b64      = base64encode(file("../init.sql"))
  }))
}

resource "azurerm_network_interface" "database-nic" {
  name                = "${var.database_vm_name}-nic"
  location            = azurerm_resource_group.nebo-app-rg.location
  resource_group_name = azurerm_resource_group.nebo-app-rg.name

  ip_configuration {
    name                          = "${var.database_vm_name}-ipconfig"
    subnet_id                     = azurerm_subnet.private-subnet.id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.database-public-ip.id
  }
}
