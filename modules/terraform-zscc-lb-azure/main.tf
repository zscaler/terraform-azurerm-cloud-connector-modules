#-----------------------------------------------------------------------------------------------------------------
# Create internal load balancer. Load balancer uses cloud connector service interfaces as its backend pool
# and configured HTTP Probe Port for health checking

# Create Standard Load Balancer
resource "azurerm_lb" "cc-lb" {
  name                       = "${var.name_prefix}-cc-lb-${var.resource_tag}"
  location                     = var.location
  resource_group_name          = var.resource_group
  sku                          = "Standard"

  tags = var.global_tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
}
  
  
  frontend_ip_configuration {
    name                          = "${var.name_prefix}-cc-lb-ip-${var.resource_tag}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}


# Create backend address pool for load balancer
resource "azurerm_lb_backend_address_pool" "cc-lb-backend-pool" {
  name                = "${var.name_prefix}-cc-lb-backend-${var.resource_tag}"
  loadbalancer_id     = azurerm_lb.cc-lb.id
}


# Define load balancer health probe parameters
resource "azurerm_lb_probe" "cc-lb-probe" {
  name                = "${var.name_prefix}-cc-lb-probe-${var.resource_tag}"
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.cc-lb.id
  protocol            = "Http"
  port                = var.http_probe_port 
  request_path        = "/?cchealth"
}


# Create load balancer rule
resource "azurerm_lb_rule" "cc-lb-rule" {
  name                           = "${var.name_prefix}-cc-lb-rule-${var.resource_tag}"
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.cc-lb.id
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = azurerm_lb.cc-lb.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.cc-lb-probe.id
  load_distribution              = var.load_distribution
}