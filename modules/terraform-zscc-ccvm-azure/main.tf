################################################################################
# Create Cloud Connector Management Interfaces and associate NSG
################################################################################
# Create CC Management interfaces
resource "azurerm_network_interface" "cc_mgmt_nic" {
  count               = local.valid_cc_create ? var.cc_count : 0
  name                = "${var.name_prefix}-ccvm-${count.index + 1}-mgmt-nic-${var.resource_tag}"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "${var.name_prefix}-ccvm-mgmt-nic-conf-${var.resource_tag}"
    subnet_id                     = element(var.mgmt_subnet_id, count.index)
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }

  tags = var.global_tags
}


################################################################################
# Associate CC Management interface to Management NSG
################################################################################
resource "azurerm_network_interface_security_group_association" "cc_mgmt_nic_association" {
  count                     = var.cc_count
  network_interface_id      = azurerm_network_interface.cc_mgmt_nic[count.index].id
  network_security_group_id = element(var.mgmt_nsg_id, count.index)

  depends_on = [azurerm_network_interface.cc_mgmt_nic]
}


################################################################################
# Create Cloud Connector Service Interfaces for Small Cloud Connector sizes.
# This interface becomes LB0 interface for Medium/Large Cloud Connector sizes
################################################################################
resource "azurerm_network_interface" "cc_service_nic" {
  count                         = local.valid_cc_create ? var.cc_count : 0
  name                          = "${var.name_prefix}-ccvm-${count.index + 1}-fwd-nic-${var.resource_tag}"
  location                      = var.location
  resource_group_name           = var.resource_group
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerated_networking_enabled

  ip_configuration {
    name                          = "${var.name_prefix}-ccvm-fwd-nic-conf-${var.resource_tag}"
    subnet_id                     = element(var.service_subnet_id, count.index)
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }

  tags = var.global_tags

  depends_on = [azurerm_network_interface.cc_mgmt_nic]
}


################################################################################
# Associate CC Service/Forwarding NIC to Service NSG
################################################################################
resource "azurerm_network_interface_security_group_association" "cc_service_nic_association" {
  count                     = local.valid_cc_create ? var.cc_count : 0
  network_interface_id      = azurerm_network_interface.cc_service_nic[count.index].id
  network_security_group_id = element(var.service_nsg_id, count.index)

  depends_on = [azurerm_network_interface.cc_service_nic]
}


################################################################################
# Create Cloud Connector Service Interface #1 for Medium/Large CC. 
# This resource will not be created for "small" CC instances
################################################################################
resource "azurerm_network_interface" "cc_service_nic_1" {
  count                         = local.valid_cc_create && var.cc_instance_size != "small" ? var.cc_count : 0
  name                          = "${var.name_prefix}-ccvm-${count.index + 1}-service-nic-1-${var.resource_tag}"
  location                      = var.location
  resource_group_name           = var.resource_group
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerated_networking_enabled

  ip_configuration {
    name                          = "${var.name_prefix}-cc-service-nic-1-conf-${var.resource_tag}"
    subnet_id                     = element(var.service_subnet_id, count.index)
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }

  tags = var.global_tags

  depends_on = [azurerm_network_interface.cc_service_nic]
}


################################################################################
# Associate CC Service-1 NIC to Service NSG
################################################################################
resource "azurerm_network_interface_security_group_association" "cc_service_nic_1_association" {
  count                     = var.cc_instance_size != "small" ? length(azurerm_network_interface.cc_service_nic_1) : 0
  network_interface_id      = azurerm_network_interface.cc_service_nic_1[count.index].id
  network_security_group_id = element(var.service_nsg_id, count.index)

  depends_on = [azurerm_network_interface.cc_service_nic_1]
}


################################################################################
# Create Cloud Connector Service Interface #2 for Medium/Large CC. 
# This resource will not be created for "small" CC instances
################################################################################
resource "azurerm_network_interface" "cc_service_nic_2" {
  count                         = local.valid_cc_create && var.cc_instance_size != "small" ? var.cc_count : 0
  name                          = "${var.name_prefix}-ccvm-${count.index + 1}-service-nic-2-${var.resource_tag}"
  location                      = var.location
  resource_group_name           = var.resource_group
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerated_networking_enabled

  ip_configuration {
    name                          = "${var.name_prefix}-cc-service-nic-2-conf-${var.resource_tag}"
    subnet_id                     = element(var.service_subnet_id, count.index)
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }

  tags = var.global_tags

  depends_on = [azurerm_network_interface.cc_service_nic]
}


################################################################################
# Associate CC Service-2 NIC to Service NSG
################################################################################
resource "azurerm_network_interface_security_group_association" "cc_service_nic_2_association" {
  count                     = var.cc_instance_size != "small" ? length(azurerm_network_interface.cc_service_nic_2) : 0
  network_interface_id      = azurerm_network_interface.cc_service_nic_2[count.index].id
  network_security_group_id = element(var.service_nsg_id, count.index)

  depends_on = [azurerm_network_interface.cc_service_nic_2]
}


################################################################################
# Create Cloud Connector Service Interface #3 for Large CC. 
# This resource will not be created for "small" or "medium" CC instances
################################################################################
resource "azurerm_network_interface" "cc_service_nic_3" {
  count                         = local.valid_cc_create && var.cc_instance_size == "large" ? var.cc_count : 0
  name                          = "${var.name_prefix}-ccvm-${count.index + 1}-service-nic-3-${var.resource_tag}"
  location                      = var.location
  resource_group_name           = var.resource_group
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerated_networking_enabled

  ip_configuration {
    name                          = "${var.name_prefix}-cc-service-nic-3-conf-${var.resource_tag}"
    subnet_id                     = element(var.service_subnet_id, count.index)
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }

  tags = var.global_tags

  depends_on = [azurerm_network_interface.cc_service_nic]
}


################################################################################
# Associate CC Service-3 NIC to Service NSG
################################################################################
resource "azurerm_network_interface_security_group_association" "cc_service_nic_3_association" {
  count                     = var.cc_instance_size == "large" ? length(azurerm_network_interface.cc_service_nic_3) : 0
  network_interface_id      = azurerm_network_interface.cc_service_nic_3[count.index].id
  network_security_group_id = element(var.service_nsg_id, count.index)

  depends_on = [azurerm_network_interface.cc_service_nic_3]
}


################################################################################
# Create Cloud Connector Network Interface to Load Balancer associations
################################################################################
# Associate CC forwarding interface to Azure LB backend pool
resource "azurerm_network_interface_backend_address_pool_association" "cc_vm_service_nic_lb_association" {
  count                   = var.lb_association_enabled == true && var.cc_instance_size == "small" ? var.cc_count : 0
  network_interface_id    = azurerm_network_interface.cc_service_nic[count.index].id
  ip_configuration_name   = "${var.name_prefix}-ccvm-fwd-nic-conf-${var.resource_tag}"
  backend_address_pool_id = var.backend_address_pool

  depends_on = [var.backend_address_pool]
}


################################################################################
# Create Cloud Connector VM
################################################################################
resource "azurerm_linux_virtual_machine" "cc_vm" {
  count                      = local.valid_cc_create ? var.cc_count : 0
  name                       = "${var.name_prefix}-ccvm-${count.index + 1}-${var.resource_tag}"
  location                   = var.location
  resource_group_name        = var.resource_group
  size                       = var.ccvm_instance_type
  availability_set_id        = local.zones_supported == false ? azurerm_availability_set.cc_availability_set[0].id : null
  zone                       = local.zones_supported ? element(var.zones, count.index) : null
  encryption_at_host_enabled = var.encryption_at_host_enabled

  # Cloud Connector requires that the ordering of network_interface_ids associated are #1/mgmt, #2/service (or lb for med/lrg CC), #3/service-1, #4/service-2, #5/service-3 
  network_interface_ids = [
    azurerm_network_interface.cc_mgmt_nic[count.index].id,
    azurerm_network_interface.cc_service_nic[count.index].id,
    try(azurerm_network_interface.cc_service_nic_1[count.index].id, azurerm_network_interface.cc_service_nic[count.index].id), ## dup cc_service_nic as fallback if interface is not created based on cc_instance_size selection 
    try(azurerm_network_interface.cc_service_nic_2[count.index].id, azurerm_network_interface.cc_service_nic[count.index].id),
    try(azurerm_network_interface.cc_service_nic_3[count.index].id, azurerm_network_interface.cc_service_nic[count.index].id)
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

  dynamic "source_image_reference" {
    for_each = var.ccvm_source_image_id == null ? [var.ccvm_image_publisher] : []

    content {
      publisher = var.ccvm_image_publisher
      offer     = var.ccvm_image_offer
      sku       = var.ccvm_image_sku
      version   = var.ccvm_image_version
    }
  }

  dynamic "plan" {
    for_each = var.ccvm_source_image_id == null ? [var.ccvm_image_publisher] : []

    content {
      publisher = var.ccvm_image_publisher
      name      = var.ccvm_image_sku
      product   = var.ccvm_image_offer
    }
  }

  source_image_id = var.ccvm_source_image_id != null ? var.ccvm_source_image_id : null

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  tags = var.global_tags

  depends_on = [
    azurerm_network_interface_security_group_association.cc_mgmt_nic_association,
    azurerm_network_interface_security_group_association.cc_service_nic_association,
    azurerm_network_interface_backend_address_pool_association.cc_vm_service_nic_lb_association,
    var.backend_address_pool
  ]

  lifecycle {
    ignore_changes = [network_interface_ids] #ignore the fallback network interface association for small/medium CCs so terraform doesn't think it needs to update them on subsequent applies
  }
}


################################################################################
# If CC zones are not manually defined, create availability set.
# If zones_enabled is set to true and the Azure region supports zones, this
# resource will not be created.
################################################################################
resource "azurerm_availability_set" "cc_availability_set" {
  count                       = local.zones_supported == false ? 1 : 0
  name                        = "${var.name_prefix}-ccvm-availability-set-${var.resource_tag}"
  location                    = var.location
  resource_group_name         = var.resource_group
  platform_fault_domain_count = local.max_fd_supported == true ? 3 : 2

  tags = var.global_tags
}


################################################################################
# Validation for Cloud Connector instance size and VM Instance Type 
# compatibilty. A file will get generated in the terraform working/root path 
# if this error gets triggered.
################################################################################
resource "null_resource" "error_checker" {
  count = local.valid_cc_create ? 0 : 1 # 0 means no error is thrown, else throw error
  provisioner "local-exec" {
    command = <<EOF
      echo "Cloud Connector parameters were invalid. No appliances were created. Please check the documentation and cc_instance_size / ccvm_instance_type values that were chosen" >> ${path.root}/errorlog.txt
EOF
  }
}
