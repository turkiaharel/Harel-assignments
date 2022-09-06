
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.20.0"
    }
  }
}

#Connecting to Azure 
provider "azurerm" {
  subscription_id = "23d20c39-1ccc-4096-94c4-71f1df475942"
  client_id = "6f66c609-c46a-4bcf-88a2-71833ab2f1ee"
  client_secret = "_gO8Q~1XMyds0X.A2azFvNMybM6iTlDfVMNCfaZh"
  tenant_id = "1a3ee19b-c83c-4314-9610-96c87ef6f29d"
  features {}
}

#Createing resource group RG01
resource "azurerm_resource_group" "RG01" {
    name =  "RG01"
    location = "North Europe"
}

#Createing network settings in region North Europe
#Virtual network VN01
resource "azurerm_virtual_network" "VN01" {
  name                = "VN01"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.RG01.name
  address_space       = ["192.168.0.0/16"]
 dns_servers         = ["192.168.1.1", "192.168.2.1"]
}
#Subnet SubA
resource "azurerm_subnet" "subA" {
  name                 = "subA"
  resource_group_name  = azurerm_resource_group.RG01.name
  virtual_network_name = azurerm_virtual_network.VN01.name
  address_prefixes     = ["192.168.1.0/24"]
}
#Subnet SubB
resource "azurerm_subnet" "subB" {
  name                 = "subB"
  resource_group_name  = azurerm_resource_group.RG01.name
  virtual_network_name = azurerm_virtual_network.VN01.name
  address_prefixes     = ["192.168.2.0/24"]
}
#Nettwork interface VM_interface01
resource "azurerm_network_interface" "VM_interface01" {
  name                = "VM_interface01"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.RG01.name
  ip_configuration {
    name                          = "Internal"
    subnet_id                     = azurerm_subnet.subA.id
    private_ip_address_allocation = "Dynamic"
  }
}
#Nettwork interface VM_interface02
resource "azurerm_network_interface" "VM_interface02" {
  name                = "VM_interface02"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.RG01.name
  ip_configuration {
    name                          = "Internal"
    subnet_id                     = azurerm_subnet.subB.id
    private_ip_address_allocation = "Dynamic"
  }
}
#Create 2 Virtual servers in North Europe NE_VM01 and NE_VM02
resource "azurerm_windows_virtual_machine" "NE_VM01" {
  name                  = "NE_VM01"
  location              = "North Europe"
  resource_group_name   = azurerm_resource_group.RG01.name
  size                  = "Standard_F2"
  admin_username = "testadmin"
  admin_password = "Password1234!"
  computer_name =  "NE-VM01"
  network_interface_ids = [
    azurerm_network_interface.VM_interface01.id,
  ]
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
 os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
resource "azurerm_windows_virtual_machine" "NE_VM02" {
  name                  = "NE_VM02"
  location              = "North Europe"
  resource_group_name   = azurerm_resource_group.RG01.name
  size                  = "Standard_F2"
  admin_username = "testadmin"
  admin_password = "Password1234!"
  computer_name =  "NE-VM02"
  network_interface_ids = [
    azurerm_network_interface.VM_interface02.id,
  ]
  
source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
 os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

#Create public IP for load balance
resource "azurerm_public_ip" "PublicIP_LB01" {
  name                = "PublicIP_LB01"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.RG01.name
  allocation_method   = "Static"
  sku                  = "Standard"
  domain_name_label = "lb01ip"
}
#Create load balance LB01
resource "azurerm_lb" "LB01" {
  name                = "LB01"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.RG01.name
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.PublicIP_LB01.id
  }
  sku                    = "Standard"
}
resource "azurerm_lb_backend_address_pool" "poolA" {
  loadbalancer_id = azurerm_lb.LB01.id
  name            = "poolA"
}
#Connect load balance pool address to VMs
resource "azurerm_lb_backend_address_pool_address" "VM01_Address" {
  name                                = "VM01_Address"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.poolA.id
  virtual_network_id                  = azurerm_virtual_network.VN01.id
  ip_address                          = azurerm_network_interface.VM_interface01.private_ip_address
}
resource "azurerm_lb_backend_address_pool_address" "VM02_Address" {
  name                                = "VM02_Address"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.poolA.id
  virtual_network_id                  = azurerm_virtual_network.VN01.id
  ip_address                          = azurerm_network_interface.VM_interface02.private_ip_address
}


#Createing network settings in region West Europe
resource "azurerm_virtual_network" "VN02" {
  name                = "VN02"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.RG01.name
  address_space       = ["10.10.0.0/16"]
 dns_servers         = ["10.10.1.1", "10.10.2.1"]
}
resource "azurerm_subnet" "subC" {
  name                 = "subC"
  resource_group_name  = azurerm_resource_group.RG01.name
  virtual_network_name = azurerm_virtual_network.VN02.name
  address_prefixes     = ["10.10.1.0/24"]
}
resource "azurerm_subnet" "subD" {
  name                 = "subD"
  resource_group_name  = azurerm_resource_group.RG01.name
  virtual_network_name = azurerm_virtual_network.VN02.name
  address_prefixes     = ["10.10.2.0/24"]
}
resource "azurerm_network_interface" "VM_interface03" {
  name                = "VM_interface03"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.RG01.name
  ip_configuration {
    name                          = "Internal"
    subnet_id                     = azurerm_subnet.subC.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "VM_interface04" {
  name                = "VM_interface04"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.RG01.name
  ip_configuration {
    name                          = "Internal"
    subnet_id                     = azurerm_subnet.subD.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Create 2 Virtual servers in North Europe WE_VM01 and WE_VM02
resource "azurerm_windows_virtual_machine" "WE_VM01" {
  name                  = "WE_VM01"
  location              = "West Europe"
  resource_group_name   = azurerm_resource_group.RG01.name
  size                  = "Standard_F2"
  admin_username = "testadmin"
  admin_password = "Password1234!"
  computer_name =  "WE-VM01"
  network_interface_ids = [
    azurerm_network_interface.VM_interface03.id,
  ]
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
 os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
resource "azurerm_windows_virtual_machine" "WE_VM02" {
  name                  = "WE_VM02"
  location              = "West Europe"
  resource_group_name   = azurerm_resource_group.RG01.name
  size                  = "Standard_F2"
  admin_username = "testadmin"
  admin_password = "Password1234!"
  computer_name =  "WE-VM02"
  network_interface_ids = [
    azurerm_network_interface.VM_interface04.id,
  ]
  
source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
 os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

#Create public IP for load balance
resource "azurerm_public_ip" "PublicIP_LB02" {
  name                = "PublicIP_LB02"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.RG01.name
  allocation_method   = "Static"
  sku                  = "Standard"
  domain_name_label = "lb02ip"
}
#Create load balance LB02
resource "azurerm_lb" "LB02" {
  name                = "LB02"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.RG01.name
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.PublicIP_LB02.id
  }
  sku                    = "Standard"
}
resource "azurerm_lb_backend_address_pool" "poolB" {
  loadbalancer_id = azurerm_lb.LB02.id
  name            = "poolB"
}

#Connect load balance pool address to VMs
resource "azurerm_lb_backend_address_pool_address" "VM03_Address" {
  name                                = "VM03_Address"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.poolB.id
  virtual_network_id                  = azurerm_virtual_network.VN02.id
  ip_address                          = azurerm_network_interface.VM_interface03.private_ip_address
}
resource "azurerm_lb_backend_address_pool_address" "VM04_Address" {
  name                                = "VM04_Address"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.poolB.id
  virtual_network_id                  = azurerm_virtual_network.VN02.id
  ip_address                          = azurerm_network_interface.VM_interface04.private_ip_address
}

#Creating Azure Trafic Manager Profile RG01-TMP01
resource "azurerm_traffic_manager_profile" "RG01-TMP01" {
  name                   = "RG01-TMP01"
  resource_group_name    = azurerm_resource_group.RG01.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "RG01-TMP01"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

}

#Creating Azure Trafic Manager Profile endpoint TMG01_EP01
resource "azurerm_traffic_manager_azure_endpoint" "TMG01_EP01" {
  name               = "GeoTMG01_EP01"
  profile_id         = azurerm_traffic_manager_profile.RG01-TMP01.id
  target_resource_id = azurerm_public_ip.PublicIP_LB01.id
}
#Creating Azure Trafic Manager Profile endpoint TMG01_EP02
resource "azurerm_traffic_manager_azure_endpoint" "GeoTMG01_EP02" {
  name               = "GeoTMG01_EP02"
  profile_id         = azurerm_traffic_manager_profile.RG01-TMP01.id
  target_resource_id = azurerm_public_ip.PublicIP_LB02.id
}