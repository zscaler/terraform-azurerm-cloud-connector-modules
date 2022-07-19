# Validation for Cloud Connector instance size and VM Instance Type compatibilty. A file will get generated in root path if this error gets triggered.
resource "null_resource" "error-checker" {
  count = local.valid_cc_create ? 0 : 1 # 0 means no error is thrown, else throw error
  provisioner "local-exec" {
    command = <<EOF
      echo "Cloud Connector parameters were invalid. No appliances were created. Please check the documentation and cc_instance_size / ccvm_instance_type values that were chosen" >> ${path.root}/errorlog.txt
EOF
  }
}

data "azurerm_subscription" "current-subscription" {}


# Create CC Management interfaces
resource "azurerm_network_interface" "cc-mgmt-nic" {
  count               = local.valid_cc_create ? var.cc_count : 0
  name                = "${var.name_prefix}-ccvm-${count.index + 1}-mgmt-nic-${var.resource_tag}"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "${var.name_prefix}-cc-mgmt-nic-conf-${var.resource_tag}"
    subnet_id                     = element(var.mgmt_subnet_id, count.index)
    private_ip_address_allocation = "dynamic"
    primary                       = true
  }

  tags = var.global_tags
}


# Associate CC Management interface to Management NSG
resource "azurerm_network_interface_security_group_association" "cc-mgmt-nic-association" {
  count                     = var.cc_count
  network_interface_id      = azurerm_network_interface.cc-mgmt-nic[count.index].id
  network_security_group_id = element(var.mgmt_nsg_id, count.index)

  depends_on = [azurerm_network_interface.cc-mgmt-nic]
}


# Create Cloud Connector Service Interface for Small CC. This interface becomes LB0 interface for Medium/Large CC
resource "azurerm_network_interface" "cc-service-nic" {
  count                         = local.valid_cc_create ? var.cc_count : 0
  name                          = var.cc_instance_size == "small" ? "${var.name_prefix}-ccvm-${count.index + 1}-service-nic-${var.resource_tag}" : "${var.name_prefix}-ccvm-${count.index + 1}-lb-nic-${var.resource_tag}"
  location                      = var.location
  resource_group_name           = var.resource_group
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerated_networking_enabled

  ip_configuration {
    name                          = var.cc_instance_size == "small" ? "${var.name_prefix}-cc-service-nic-conf-${var.resource_tag}" : "${var.name_prefix}-cc-lb-nic-conf-${var.resource_tag}"
    subnet_id                     = element(var.service_subnet_id, count.index)
    private_ip_address_allocation = "dynamic"
    primary                       = true
  }

  tags = var.global_tags

  depends_on = [azurerm_network_interface.cc-mgmt-nic]
}

# Associate CC Service/LB NIC to Service NSG
resource "azurerm_network_interface_security_group_association" "cc-service-nic-association" {
  count                     = local.valid_cc_create ? var.cc_count : 0
  network_interface_id      = azurerm_network_interface.cc-service-nic[count.index].id
  network_security_group_id = element(var.service_nsg_id, count.index)

  depends_on = [azurerm_network_interface.cc-service-nic]
}


# Create Cloud Connector Service Interface #1 for Medium/Large CC. This resource will not be created for "small" CC instances
resource "azurerm_network_interface" "cc-service-nic-1" {
  count                         = local.valid_cc_create && var.cc_instance_size != "small" ? var.cc_count : 0
  name                          = "${var.name_prefix}-ccvm-${count.index + 1}-service-nic-1-${var.resource_tag}"
  location                      = var.location
  resource_group_name           = var.resource_group
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerated_networking_enabled

  ip_configuration {
    name                          = "${var.name_prefix}-cc-service-nic-1-conf-${var.resource_tag}"
    subnet_id                     = element(var.service_subnet_id, count.index)
    private_ip_address_allocation = "dynamic"
    primary                       = true
  }

  tags = var.global_tags

  depends_on = [azurerm_network_interface.cc-service-nic]
}

# Associate CC Service-1 NIC to Service NSG
resource "azurerm_network_interface_security_group_association" "cc-service-nic-1-association" {
  count                     = var.cc_instance_size != "small" ? length(azurerm_network_interface.cc-service-nic-1) : 0
  network_interface_id      = azurerm_network_interface.cc-service-nic-1[count.index].id
  network_security_group_id = element(var.service_nsg_id, count.index)

  depends_on = [azurerm_network_interface.cc-service-nic-1]
}


# Create Cloud Connector Service Interface #2 for Medium/Large CC. This resource will not be created for "small" CC instances
resource "azurerm_network_interface" "cc-service-nic-2" {
  count                         = local.valid_cc_create && var.cc_instance_size != "small" ? var.cc_count : 0
  name                          = "${var.name_prefix}-ccvm-${count.index + 1}-service-nic-2-${var.resource_tag}"
  location                      = var.location
  resource_group_name           = var.resource_group
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerated_networking_enabled

  ip_configuration {
    name                          = "${var.name_prefix}-cc-service-nic-2-conf-${var.resource_tag}"
    subnet_id                     = element(var.service_subnet_id, count.index)
    private_ip_address_allocation = "dynamic"
    primary                       = true
  }

  tags = var.global_tags

  depends_on = [azurerm_network_interface.cc-service-nic]
}

# Associate CC Service-2 NIC to Service NSG
resource "azurerm_network_interface_security_group_association" "cc-service-nic-2-association" {
  count                     = var.cc_instance_size != "small" ? length(azurerm_network_interface.cc-service-nic-2) : 0
  network_interface_id      = azurerm_network_interface.cc-service-nic-2[count.index].id
  network_security_group_id = element(var.service_nsg_id, count.index)

  depends_on = [azurerm_network_interface.cc-service-nic-2]
}


# Create Cloud Connector Service Interface #3 for Large CC. This resource will not be created for "small" or "medium" CC instances
resource "azurerm_network_interface" "cc-service-nic-3" {
  count                         = local.valid_cc_create && var.cc_instance_size == "large" ? var.cc_count : 0
  name                          = "${var.name_prefix}-ccvm-${count.index + 1}-service-nic-3-${var.resource_tag}"
  location                      = var.location
  resource_group_name           = var.resource_group
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerated_networking_enabled

  ip_configuration {
    name                          = "${var.name_prefix}-cc-service-nic-3-conf-${var.resource_tag}"
    subnet_id                     = element(var.service_subnet_id, count.index)
    private_ip_address_allocation = "dynamic"
    primary                       = true
  }

  tags = var.global_tags

  depends_on = [azurerm_network_interface.cc-service-nic]
}

# Associate CC Service-3 NIC to Service NSG
resource "azurerm_network_interface_security_group_association" "cc-service-nic-3-association" {
  count                     = var.cc_instance_size == "large" ? length(azurerm_network_interface.cc-service-nic-3) : 0
  network_interface_id      = azurerm_network_interface.cc-service-nic-3[count.index].id
  network_security_group_id = element(var.service_nsg_id, count.index)

  depends_on = [azurerm_network_interface.cc-service-nic-3]
}


# Associate "small" CC service interface to Azure LB backend pool. This resource will not be created for "medium" or "large" CC instances
resource "azurerm_network_interface_backend_address_pool_association" "cc-vm-service-nic-lb-association" {
  count                   = var.lb_association_enabled == true && var.cc_instance_size == "small" ? var.cc_count : 0
  network_interface_id    = azurerm_network_interface.cc-service-nic[count.index].id
  ip_configuration_name   = "${var.name_prefix}-cc-service-nic-conf-${var.resource_tag}"
  backend_address_pool_id = var.backend_address_pool

  depends_on = [var.backend_address_pool]
}

# Associate "medium/large" CC service interface-1 to Azure LB backend pool. This resource will not be created for "small" CC instances
resource "azurerm_network_interface_backend_address_pool_association" "cc-vm-service-1-nic-lb-association" {
  count                   = var.lb_association_enabled == true && var.cc_instance_size != "small" ? var.cc_count : 0
  network_interface_id    = azurerm_network_interface.cc-service-nic-1[count.index].id
  ip_configuration_name   = "${var.name_prefix}-cc-service-nic-1-conf-${var.resource_tag}"
  backend_address_pool_id = var.backend_address_pool

  depends_on = [var.backend_address_pool]
}

# Associate "medium/large" CC service interface-2 to Azure LB backend pool. This resource will not be created for "small" CC instances
resource "azurerm_network_interface_backend_address_pool_association" "cc-vm-service-2-nic-lb-association" {
  count                   = var.lb_association_enabled == true && var.cc_instance_size != "small" ? var.cc_count : 0
  network_interface_id    = azurerm_network_interface.cc-service-nic-2[count.index].id
  ip_configuration_name   = "${var.name_prefix}-cc-service-nic-2-conf-${var.resource_tag}"
  backend_address_pool_id = var.backend_address_pool

  depends_on = [var.backend_address_pool]
}

# Associate "large" CC service interface-3 to Azure LB backend pool. This resource will not be created for "small" or "medium" CC instances
resource "azurerm_network_interface_backend_address_pool_association" "cc-vm-service-3-nic-lb-association" {
  count                   = var.lb_association_enabled == true && var.cc_instance_size == "large" ? var.cc_count : 0
  network_interface_id    = azurerm_network_interface.cc-service-nic-3[count.index].id
  ip_configuration_name   = "${var.name_prefix}-cc-service-nic-3-conf-${var.resource_tag}"
  backend_address_pool_id = var.backend_address_pool

  depends_on = [var.backend_address_pool]
}

# Create Cloud Connector VM
resource "azurerm_linux_virtual_machine" "cc-vm" {
  count               = local.valid_cc_create ? var.cc_count : 0
  name                = "${var.name_prefix}-ccvm-${count.index + 1}-${var.resource_tag}"
  location            = var.location
  resource_group_name = var.resource_group
  size                = var.ccvm_instance_type
  availability_set_id = local.zones_supported == false ? azurerm_availability_set.cc-availability-set.*.id[0] : null
  zone                = local.zones_supported ? element(var.zones, count.index) : null

  # Cloud Connector requires that the ordering of network_interface_ids associated are #1/mgmt, #2/service (or lb for med/lrg CC), #3/service-1, #4/service-2, #5/service-3 
  network_interface_ids = [
    azurerm_network_interface.cc-mgmt-nic[count.index].id,
    azurerm_network_interface.cc-service-nic[count.index].id,
    try(azurerm_network_interface.cc-service-nic-1[count.index].id, azurerm_network_interface.cc-service-nic[count.index].id), ## dup cc-service-nic as fallback if interface is not created based on cc_instance_size selection 
    try(azurerm_network_interface.cc-service-nic-2[count.index].id, azurerm_network_interface.cc-service-nic[count.index].id),
    try(azurerm_network_interface.cc-service-nic-3[count.index].id, azurerm_network_interface.cc-service-nic[count.index].id)
  ]

  computer_name  = "${var.name_prefix}-ccvm-${count.index + 1}-${var.resource_tag}"
  admin_username = var.cc_username
  custom_data    = base64encode(var.user_data)

  admin_ssh_key {
    username   = var.cc_username
    public_key = "${trimspace(var.ssh_key)} ${var.cc_username}@me.io"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.ccvm_image_publisher
    offer     = var.ccvm_image_offer
    sku       = var.ccvm_image_sku
    version   = var.ccvm_image_version
  }

  plan {
    publisher = var.ccvm_image_publisher
    name      = var.ccvm_image_sku
    product   = var.ccvm_image_offer
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  tags = var.global_tags

  depends_on = [
    azurerm_network_interface_security_group_association.cc-mgmt-nic-association,
    azurerm_network_interface_security_group_association.cc-service-nic-association,
    azurerm_network_interface_backend_address_pool_association.cc-vm-service-nic-lb-association,
    var.backend_address_pool
  ]

  lifecycle {
    ignore_changes = [network_interface_ids]
  }
}


# If CC zones are not manually defined, create availability set
resource "azurerm_availability_set" "cc-availability-set" {
  count                       = local.zones_supported == false ? 1 : 0
  name                        = "${var.name_prefix}-ccvm-availability-set-${var.resource_tag}"
  location                    = var.location
  resource_group_name         = var.resource_group
  platform_fault_domain_count = local.max_fd_supported == true ? 3 : 2

  tags = var.global_tags
}
