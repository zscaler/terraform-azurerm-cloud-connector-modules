resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}


resource "azurerm_public_ip" "public_ip" {
  count               = var.workload_count
  name                = "${var.prefix}-vdi-${count.index + 1}-public-ip-${var.resource_tag}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
}

resource "azurerm_network_interface" "cca-vdi-network" {
  count               = var.workload_count
  name                = "${var.prefix}-vdi-${count.index + 1}-network-${var.resource_tag}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
  }
}

# Create virtual machine
resource "azurerm_windows_virtual_machine" "cca-vdi" {
  count                 = var.workload_count
  name                  = "vdi-${count.index + 1}-${var.resource_tag}"
  admin_username        = var.admin_username
  admin_password        = random_password.password.result
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.cca-vdi-network[count.index].id]
  size                  = "Standard_D2s_v3"
  zone                  = "1"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "office-365"
    sku       = "win10-22h2-avd-m365"
    version   = "latest"
  }

  # Enable WinRM for remote management
  winrm_listener {
    protocol = "Http"
  }

  # Configure WinRM client to allow unencrypted traffic for remote connections
  user_data = base64encode(<<-EOF
    <powershell>
    # Enable unencrypted traffic on WinRM client
    Set-Item -Path WSMan:\localhost\Client\AllowUnencrypted -Value $true -Force
    
    # Also set registry key for client configuration
    reg add "HKLM\Software\Policies\Microsoft\Windows\WinRM\Client" /v AllowUnencrypted /t REG_DWORD /d 1 /f
    
    # Restart WinRM service to apply changes
    Restart-Service WinRM -Force
    
    Write-Host "WinRM client configuration completed"
    </powershell>
  EOF
  )
}

resource "azurerm_route_table" "cca-vdi-routetable" {
  name                = "${var.prefix}-vdi-route-table-${var.resource_tag}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  route {
    name                   = "${var.prefix}-vdi-route-${var.resource_tag}"
    address_prefix         = "185.46.212.80/32"
    next_hop_type          = "VirtualAppliance"
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
    name                       = "AllowWinRMHTTPInbound"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowWinRMHTTPSInbound"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "cc-vdi"
  }
}

resource "azurerm_network_interface_security_group_association" "cca-vdi-nsg-association" {
  count                     = var.workload_count
  network_interface_id      = azurerm_network_interface.cca-vdi-network[count.index].id
  network_security_group_id = azurerm_network_security_group.cca-vdi-nsg.id
}

resource "azurerm_virtual_machine_extension" "CustomScriptExtensionNoToken" {
  count                = var.cca_template_url == null && var.cca_token == null ? var.workload_count : 0
  name                 = "${var.prefix}-CustomScriptExtension-vm-${count.index + 1}-${var.resource_tag}"
  virtual_machine_id   = azurerm_windows_virtual_machine.cca-vdi[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
        {
          "commandToExecute": "powershell.exe -ExecutionPolicy Bypass -Command \"New-Item -ItemType Directory -Force -Path 'C:\\temp'; Enable-PSRemoting -Force -SkipNetworkProfileCheck; Set-Item WSMan:\\localhost\\Client\\TrustedHosts -Value '*' -Force; winrm set winrm/config/service '@{AllowUnencrypted=\"true\"}'; winrm set winrm/config/service/auth '@{Basic=\"true\"}'; Set-NetFirewallRule -Name 'WINRM-HTTP-In-TCP-PUBLIC' -RemoteAddress Any -ErrorAction SilentlyContinue; New-NetFirewallRule -Name 'WinRM-HTTP' -DisplayName 'WinRM HTTP' -Enabled True -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow -ErrorAction SilentlyContinue; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://z0luvmca.blob.core.windows.net/zsvdiinstaller/ZSVDIInstaller_1.4.0.5_x64.msi' -OutFile 'C:\\temp\\ZSVDIInstaller_1.4.0.5_x64.msi'; Start-Process msiexec.exe -ArgumentList '/i C:\\temp\\ZSVDIInstaller_1.4.0.5_x64.msi /qn' -Wait\""
        }
    SETTINGS

  timeouts {
    create = "30m"
    update = "30m"
    delete = "10m"
  }
}

resource "azurerm_virtual_machine_extension" "CustomScriptExtension" {
  count                = var.cca_template_url != null && var.cca_token != null ? var.workload_count : 0
  name                 = "${var.prefix}-CustomScriptExtension-vm-${count.index + 1}-${var.resource_tag}"
  virtual_machine_id   = azurerm_windows_virtual_machine.cca-vdi[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
        {
          "commandToExecute": "powershell.exe -ExecutionPolicy Bypass -Command \"New-Item -ItemType Directory -Force -Path 'C:\\temp'; Enable-PSRemoting -Force -SkipNetworkProfileCheck; Set-Item WSMan:\\localhost\\Client\\TrustedHosts -Value '*' -Force; winrm set winrm/config/service '@{AllowUnencrypted=\\\"true\\\"}'; winrm set winrm/config/service/auth '@{Basic=\\\"true\\\"}'; New-ItemProperty -Path HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System -Name LocalAccountTokenFilterPolicy -Value 1 -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://z0luvmca.blob.core.windows.net/zsvdiinstaller/ZSVDIInstaller_1.4.0.5_x64.msi' -OutFile 'C:\\temp\\ZSVDIInstaller_1.4.0.5_x64.msi'; Start-Process msiexec.exe -ArgumentList '/i C:\\temp\\ZSVDIInstaller_1.4.0.5_x64.msi PROVURL=${var.cca_template_url} TOKEN=${var.cca_token} MODE=1 ONBOARD=1 /qn' -Wait\""
        }
    SETTINGS

  timeouts {
    create = "30m"
    update = "30m"
    delete = "10m"
  }
}

# WindowsOpenSSH extension removed - using WinRM instead for remote management
# WinRM is configured in CustomScriptExtension and is more reliable for Windows
