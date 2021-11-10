provider "azurerm" {
  features {}
}

locals {
  id_helselog = "project-helselogistikk-0001"
  id_kurs     = "kurs-dips-ahus-0001"
  location    = "norwayeast"
}

#resource group for helselog instance
resource "azurerm_resource_group" "rg_helselog" {
  name     = local.id_helselog
  location = local.location
}

#resource group for helselog instance
resource "azurerm_resource_group" "rg_kurs" {
  name     = local.id_kurs
  location = local.location
}

### Virtual network for Herlselog instance
resource "azurerm_virtual_network" "vnet_helselog" {
  name                = local.id_helselog
  location            = azurerm_resource_group.rg_helselog.location
  resource_group_name = azurerm_resource_group.rg_helselog.name
  address_space       = ["10.0.0.0/16"]
}

### Subnet for web, app, db at Herlselog instance
resource "azurerm_subnet" "subnet_helselog_web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.rg_helselog.name
  virtual_network_name = azurerm_virtual_network.vnet_helselog.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_subnet" "subnet_helselog_app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.rg_helselog.name
  virtual_network_name = azurerm_virtual_network.vnet_helselog.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet" "subnet_helselog_db" {
  name                 = "db-subnet"
  resource_group_name  = azurerm_resource_group.rg_helselog.name
  virtual_network_name = azurerm_virtual_network.vnet_helselog.name
  address_prefixes     = ["10.0.3.0/24"]
}

### Virtual network for Kurs instance
resource "azurerm_virtual_network" "vnet_kurs" {
  name                = local.id_kurs
  location            = azurerm_resource_group.rg_kurs.location
  resource_group_name = azurerm_resource_group.rg_kurs.name
  address_space       = ["10.1.0.0/16"]
}

### Subnet for web, app, db at Kurs instance
resource "azurerm_subnet" "subnet_kurs_web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.rg_kurs.name
  virtual_network_name = azurerm_virtual_network.vnet_kurs.name
  address_prefixes     = ["10.1.1.0/24"]
}
resource "azurerm_subnet" "subnet_kurs_app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.rg_kurs.name
  virtual_network_name = azurerm_virtual_network.vnet_kurs.name
  address_prefixes     = ["10.1.2.0/24"]
}
resource "azurerm_subnet" "subnet_kurs_db" {
  name                 = "db-subnet"
  resource_group_name  = azurerm_resource_group.rg_kurs.name
  virtual_network_name = azurerm_virtual_network.vnet_kurs.name
  address_prefixes     = ["10.1.3.0/24"]
}

### Network Interface Cards (NIC) for web, app, db at Helselog instance
resource "azurerm_network_interface" "nic_helselog_web" {
  name                = "nic-helselog-web"
  location            = azurerm_resource_group.rg_helselog.location
  resource_group_name = azurerm_resource_group.rg_helselog.name

  ip_configuration {
    name                          = "web_internal"
    subnet_id                     = azurerm_subnet.subnet_helselog_web.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic_helselog_app" {
  name                = "nic-helselog-app"
  location            = azurerm_resource_group.rg_helselog.location
  resource_group_name = azurerm_resource_group.rg_helselog.name

  ip_configuration {
    name                          = "app_internal"
    subnet_id                     = azurerm_subnet.subnet_helselog_app.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic_helselog_db" {
  name                = "nic-helselog-db"
  location            = azurerm_resource_group.rg_helselog.location
  resource_group_name = azurerm_resource_group.rg_helselog.name

  ip_configuration {
    name                          = "db_internal"
    subnet_id                     = azurerm_subnet.subnet_helselog_db.id
    private_ip_address_allocation = "Dynamic"
  }
}

### Network Interface Cards (NIC) for web, app, db at Kurs instance
resource "azurerm_network_interface" "nic_kurs_web" {
  name                = "nic-kurs-web"
  location            = azurerm_resource_group.rg_kurs.location
  resource_group_name = azurerm_resource_group.rg_kurs.name

  ip_configuration {
    name                          = "web_internal"
    subnet_id                     = azurerm_subnet.subnet_kurs_web.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic_kurs_app" {
  name                = "nic-kurs-app"
  location            = azurerm_resource_group.rg_kurs.location
  resource_group_name = azurerm_resource_group.rg_kurs.name

  ip_configuration {
    name                          = "app_internal"
    subnet_id                     = azurerm_subnet.subnet_kurs_app.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic_kurs_db" {
  name                = "nic-kurs-db"
  location            = azurerm_resource_group.rg_kurs.location
  resource_group_name = azurerm_resource_group.rg_kurs.name

  ip_configuration {
    name                          = "db_internal"
    subnet_id                     = azurerm_subnet.subnet_kurs_db.id
    private_ip_address_allocation = "Dynamic"
  }
}


#Web, App and DB instances for helselog instance

#Linux
resource "azurerm_linux_virtual_machine" "vm_linux_web_helselog" {
  name                            = "vm-linux-web-hl"
  resource_group_name             = azurerm_resource_group.rg_helselog.name
  location                        = azurerm_resource_group.rg_helselog.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "Adminpassword123"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic_helselog_web.id,
  ]
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

#Windows 
resource "azurerm_windows_virtual_machine" "vm_windows_app_helselog" {
  name                = "vm-win-app-hl"
  resource_group_name = azurerm_resource_group.rg_helselog.name
  location            = azurerm_resource_group.rg_helselog.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "Adminpassword123"
  network_interface_ids = [
    azurerm_network_interface.nic_helselog_app.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

#MS SQL Server and PaaS Database
resource "azurerm_mssql_server" "mssql_server_helselog" {
  name                         = "mssql-server-hl"
  resource_group_name          = azurerm_resource_group.rg_helselog.name
  location                     = azurerm_resource_group.rg_helselog.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "thisIsKat11"
}

resource "azurerm_mssql_database" "mssql_db_helselog" {
  name      = "mssql-db-hl"
  server_id = azurerm_mssql_server.mssql_server_helselog.id
}


##########################
########## KURS ##########
##########################

#Web, App and DB instances for helselog instance

#Linux
resource "azurerm_linux_virtual_machine" "vm_linux_web_kurs" {
  name                            = "vm-linux-web-k"
  resource_group_name             = azurerm_resource_group.rg_kurs.name
  location                        = azurerm_resource_group.rg_kurs.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "Adminpassword123"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic_kurs_web.id,
  ]
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

# #Windows 
# resource "azurerm_windows_virtual_machine" "vm_windows_app_kurs" {
#   name                = "vm-win-app-k"
#   resource_group_name = azurerm_resource_group.rg_kurs.name
#   location            = azurerm_resource_group.rg_kurs.location
#   size                = "Standard_F2"
#   admin_username      = "adminuser"
#   admin_password      = "Adminpassword123"
#   network_interface_ids = [
#     azurerm_network_interface.nic_kurs_app.id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2016-Datacenter"
#     version   = "latest"
#   }
# }

#MS SQL Server and PaaS Database
resource "azurerm_mssql_server" "mssql_server_kurs" {
  name                         = "mssql-server-k"
  resource_group_name          = azurerm_resource_group.rg_kurs.name
  location                     = azurerm_resource_group.rg_kurs.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "thisIsKat11"
}

resource "azurerm_mssql_database" "mssql_db_kurs" {
  name      = "mssql-db-k"
  server_id = azurerm_mssql_server.mssql_server_kurs.id
}