################################################################################
# Create Cloud Connector VMSS
################################################################################
resource "azurerm_linux_virtual_machine_scale_set" "cc_vmss" {
  name                       = "${var.name_prefix}-ccvmss-${var.resource_tag}"
  location                   = var.location
  resource_group_name        = var.resource_group
  sku                        = var.ccvm_instance_type
  encryption_at_host_enabled = var.encryption_at_host_enabled
  zones                      = var.zones
  # TODO: need to define this as a variable
  upgrade_mode = "Manual"
  # TODO: need to define this as a variable
  instances = 1

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

  network_interface {
    name                      = "${var.name_prefix}-ccvmss-mgmt-nic-${var.resource_tag}"
    primary                   = true
    network_security_group_id = var.mgmt_nsg_id

    ip_configuration {
      name      = "${var.name_prefix}-ccvmss-mgmt-nic-conf-${var.resource_tag}"
      primary   = true
      subnet_id = var.mgmt_subnet_id
    }
  }

  network_interface {
    name                          = "${var.name_prefix}-ccvmss-fwd-nic-${var.resource_tag}"
    enable_accelerated_networking = var.accelerated_networking_enabled
    enable_ip_forwarding          = true
    network_security_group_id     = var.service_nsg_id

    ip_configuration {
      name                                   = "${var.name_prefix}-ccvmss-fwd-nic-conf-${var.resource_tag}"
      primary                                = true
      subnet_id                              = var.service_subnet_id
      load_balancer_backend_address_pool_ids = [var.backend_address_pool]
    }
  }

  tags = var.global_tags

  depends_on = [
    var.backend_address_pool
  ]
}
