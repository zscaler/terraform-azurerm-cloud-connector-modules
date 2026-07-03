################################################################################
# Create internal load balancer. Load balancer uses Cloud Connector service 
# interfaces as its backend pool and configured HTTP Probe Port for health checking
################################################################################

# Create Public IP
resource "azurerm_public_ip" "frontend_ip" {
  name                = "${var.name_prefix}-cc-public-lb-${var.resource_tag}-ip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

################################################################################
# Create Standard Public Load Balancer
################################################################################
resource "azurerm_lb" "cc_lb" {
  name                = "${var.name_prefix}-cc-public-lb-${var.resource_tag}"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "Standard"

  tags = var.global_tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }


  frontend_ip_configuration {
    name                                               = "${var.name_prefix}-cc-public-lb-${var.resource_tag}-ip"
    public_ip_address_id                               = azurerm_public_ip.frontend_ip.id
    gateway_load_balancer_frontend_ip_configuration_id = var.gateway_load_balancer_frontend_ip_configuration_id
  }
}


################################################################################
# Create backend address pool for load balancer
################################################################################
resource "azurerm_lb_backend_address_pool" "cc_lb_backend_pool" {
  name            = "${var.name_prefix}-cc-public-lb-backend-${var.resource_tag}"
  loadbalancer_id = azurerm_lb.cc_lb.id
}


################################################################################
# Define load balancer health probe parameters
################################################################################
resource "azurerm_lb_probe" "cc_lb_probe" {
  name                = "${var.name_prefix}-cc-lb-probe-${var.resource_tag}"
  loadbalancer_id     = azurerm_lb.cc_lb.id
  protocol            = "Http"
  port                = var.http_probe_port
  request_path        = "/?cchealth"
  interval_in_seconds = var.health_check_interval
  probe_threshold     = var.probe_threshold
  number_of_probes    = var.number_of_probes
}


################################################################################
# Create load balancer rule
################################################################################
resource "azurerm_lb_rule" "cc_lb_rule" {
  name                           = "${var.name_prefix}-cc-public-lb-rule-80-${var.resource_tag}"
  loadbalancer_id                = azurerm_lb.cc_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  disable_outbound_snat          = true
  frontend_ip_configuration_name = "${var.name_prefix}-cc-public-lb-${var.resource_tag}-ip"
  probe_id                       = azurerm_lb_probe.cc_lb_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.cc_lb_backend_pool.id]
  enable_floating_ip             = true
}

resource "azurerm_lb_rule" "cc_lb_rule_443" {
  name                           = "${var.name_prefix}-cc-public-lb-rule-443-${var.resource_tag}"
  loadbalancer_id                = azurerm_lb.cc_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  disable_outbound_snat          = true
  frontend_ip_configuration_name = "${var.name_prefix}-cc-public-lb-${var.resource_tag}-ip"
  probe_id                       = azurerm_lb_probe.cc_lb_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.cc_lb_backend_pool.id]
  enable_floating_ip             = true
}
