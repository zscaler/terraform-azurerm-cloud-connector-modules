resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}


resource "azurerm_public_ip" "public_ip" {
    name                = "${var.prefix}-vdi-public-ip-${var.resource_tag}"
    resource_group_name = var.resource_group_name
    location            = var.resource_group_location
    allocation_method   = "Static"
    sku                 = "Standard"
    sku_tier            = "Regional"
}

  resource "azurerm_network_interface" "cca-vdi-network" {
    name                = "${var.prefix}-vdi-network-${var.resource_tag}"
    location            = var.resource_group_location
    resource_group_name = var.resource_group_name
    ip_configuration {
      name                          = "internal"
      subnet_id                     = var.subnet_id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.public_ip.id
    }
}

# Create virtual machine
resource "azurerm_windows_virtual_machine" "cca-vdi" {
  name                  = "${var.resource_tag}-vdi"
  admin_username        = var.admin_username
  admin_password        = random_password.password.result
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.cca-vdi-network.id]
  size                  = "Standard_D2s_v3"
  zone                 = "1"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Office-365"
    sku       = "win10-21h2-avd-m365"
    version   = "latest"
  }
}

resource "azurerm_route_table" "cca-vdi-routetable" {
    name                = "${var.prefix}-vdi-route-table-${var.resource_tag}"
    location            = var.resource_group_location
    resource_group_name = var.resource_group_name
  
    route {
      name           = "${var.prefix}-vdi-route-${var.resource_tag}"
      address_prefix = "185.46.212.80/32"
      next_hop_type  = "VirtualAppliance"
      next_hop_in_ip_address = var.primary_service_ip
    }
  
    tags = {
      environment = "cc-vdi"
    }
  }

 resource "azurerm_subnet_route_table_association" "cca-vdi-routetable-association" {
   subnet_id      = var.subnet_id
   route_table_id = azurerm_route_table.cca-vdi-routetable.id
 }

resource "azurerm_network_security_group" "cca-vdi-nsg" {
  name                = "${var.prefix}-vdi-nsg-${var.resource_tag}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowAnyRDPInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAnySSHInbound"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "cc-vdi"
  }
}

resource "azurerm_network_interface_security_group_association" "cca-vdi-nsg-association" {
  network_interface_id      = azurerm_network_interface.cca-vdi-network.id
  network_security_group_id = azurerm_network_security_group.cca-vdi-nsg.id
}


resource "azurerm_virtual_machine_extension" "CustomScriptExtenson" {
      count                = var.cca_template_url == null && var.cca_token == null ? 1 : 0 
      name                 = "${var.prefix}-CustomScriptExtension-${var.resource_tag}"
      virtual_machine_id   = azurerm_windows_virtual_machine.cca-vdi.id
      publisher            = "Microsoft.Compute"
      type                 = "CustomScriptExtension"
      type_handler_version = "1.10"
    
      settings = <<SETTINGS
        {
          "commandToExecute": "powershell.exe -Command \"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://z0luvmca.blob.core.windows.net/zsvdiinstaller/ZSVDIInstaller_1.4.0.5_x64.msi' -OutFile 'C:\\temp\\ZSVDIInstaller_1.4.0.5_x64.msi'\";powershell.exe -Command \"msiexec \"/i C:\\temp\\ZSVDIInstaller_1.4.0.5_x64.msi /qn\"\""
        }
    SETTINGS
}

resource "azurerm_virtual_machine_extension" "CustomScriptExtension" {
      count                = var.cca_template_url != null && var.cca_token != null ? 1 : 0 
      name                 = "${var.prefix}-CustomScriptExtension-${var.resource_tag}"
      virtual_machine_id   = azurerm_windows_virtual_machine.cca-vdi.id
      publisher            = "Microsoft.Compute"
      type                 = "CustomScriptExtension"
      type_handler_version = "1.10"
    
      settings = <<SETTINGS
        {
          "commandToExecute": "powershell.exe -Command \"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://z0luvmca.blob.core.windows.net/zsvdiinstaller/ZSVDIInstaller_1.4.0.5_x64.msi' -OutFile 'C:\\temp\\ZSVDIInstaller_1.4.0.5_x64.msi'\";powershell.exe -Command \"msiexec \"/i C:\\temp\\ZSVDIInstaller_1.4.0.5_x64.msi PROVURL=\"${var.cca_template_url}\" TOKEN=\"${var.cca_token}\" MODE=1 ONBOARD=1 /qn\"\""
        }
    SETTINGS
}
	
resource "azurerm_virtual_machine_extension" "WindowsOpenSSH" {
    name                 = "${var.prefix}-WindowsOpenSSH-${var.resource_tag}"
    virtual_machine_id   = azurerm_windows_virtual_machine.cca-vdi.id
    publisher            = "Microsoft.Azure.OpenSSH"
    type                 = "WindowsOpenSSH"
    type_handler_version = "3.0"
}
