provider "azurerm" {
  features {}
}
data "azurerm_resource_group" "myrg_udacity" {
  name = "Azuredevops"
  
}
output "myrg" {
  value = data.azurerm_resource_group.myrg_udacity
}
data "azurerm_image" "pkr" {
  name = "pkrserverimage"
  resource_group_name = data.azurerm_resource_group.myrg_udacity.name
  
}


resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.myrg_udacity.location
  resource_group_name = data.azurerm_resource_group.myrg_udacity.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.myrg_udacity.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  count = var.numvm
  name                = "${var.prefix}-nic${count.index}"
  resource_group_name = data.azurerm_resource_group.myrg_udacity.name
  location            = data.azurerm_resource_group.myrg_udacity.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = data.azurerm_resource_group.myrg_udacity.name
  location            = data.azurerm_resource_group.myrg_udacity.location
  allocation_method   = "Dynamic"
}
resource "azurerm_lb" "webserver" {
   name                = "loadBalancer"
   location            = data.azurerm_resource_group.myrg_udacity.location
   resource_group_name = data.azurerm_resource_group.myrg_udacity.name

   frontend_ip_configuration {
     name                 = "publicIPAddress"
     public_ip_address_id = azurerm_public_ip.pip.id
   }
 }
 resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id     = "${azurerm_lb.webserver.id}"
  name                = "serverBackendPool"
}
resource "azurerm_network_interface_backend_address_pool_association" "pool_associate" {
    count = var.numvm

      network_interface_id    = "${azurerm_network_interface.main[count.index].id}"
      ip_configuration_name   = "internal"
      backend_address_pool_id = "${azurerm_lb_backend_address_pool.backend_pool.id}"
}
resource "azurerm_network_security_group" "webserver" {
  name                = "prj1_webserver"
  location            = data.azurerm_resource_group.myrg_udacity.location
  resource_group_name = data.azurerm_resource_group.myrg_udacity.name
}
resource "azurerm_network_security_rule" "allowVNall" {
  access                     = "Allow"
  direction                  = "Inbound"
  name                       = "allow Vm comm"
  priority                   = 499
  protocol                   = "*"
  source_port_range          = "*"
  source_address_prefix      ="VirtualNetwork"
  destination_port_range     = "*"
  destination_address_prefix = "VirtualNetwork"
  resource_group_name         = data.azurerm_resource_group.myrg_udacity.name
  network_security_group_name = azurerm_network_security_group.webserver.name
}
resource "azurerm_network_security_rule" "denyhttpinbound" {
  access                     = "Deny"
  direction                  = "Inbound"
  name                       = "http-inblock"
  priority                   = 500
  protocol                   = "Tcp"
  source_port_range          = "*"
  source_address_prefix      = "*"
  destination_port_range     = "80"
  destination_address_prefix = azurerm_subnet.internal.address_prefixes[0]
  resource_group_name         = data.azurerm_resource_group.myrg_udacity.name
  network_security_group_name = azurerm_network_security_group.webserver.name
}
resource "azurerm_network_security_rule" "denyhttpoutbound" {
  access                     = "Deny"
  direction                  = "Outbound"
  name                       = "http-outblock"
  priority                   = 500
  protocol                   = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "80"
  destination_address_prefix  = azurerm_subnet.internal.address_prefixes[0]
  resource_group_name         = data.azurerm_resource_group.myrg_udacity.name
  network_security_group_name = azurerm_network_security_group.webserver.name
}
  
resource "azurerm_availability_set" "availset" {
  name                         = "${var.prefix}availset"
  location                     = data.azurerm_resource_group.myrg_udacity.location
  resource_group_name          = data.azurerm_resource_group.myrg_udacity.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}


resource "azurerm_linux_virtual_machine" "main" {
  count = var.numvm
  name = "${var.prefix}-vm${count.index}"
  tags = {
    usage = "udacity-devops-prj1"
    number = "${count.index}"
  }
  resource_group_name             = data.azurerm_resource_group.myrg_udacity.name
  location                        = data.azurerm_resource_group.myrg_udacity.location
  availability_set_id             = azurerm_availability_set.availset.id
  size                            = "Standard_D2s_v3"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

  source_image_id = data.azurerm_image.pkr.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching = "ReadWrite"
  }
}