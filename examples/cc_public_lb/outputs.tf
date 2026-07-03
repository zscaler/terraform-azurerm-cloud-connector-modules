output "public_lb_ip" {
  description = "Public IP address of the consumer Public Load Balancer frontend"
  value       = module.cc_public_lb.lb_ip
}

output "public_lb_backend_pool_id" {
  description = "Backend address pool ID of the consumer Public Load Balancer"
  value       = module.cc_public_lb.lb_backend_address_pool
}

output "ilb_ip" {
  description = "Private IP address of the downstream Internal Load Balancer frontend. Point workload route tables' default route to this IP."
  value       = module.cc_ilb.lb_ip
}

output "ilb_backend_pool_id" {
  description = "Backend address pool ID of the downstream Internal Load Balancer"
  value       = module.cc_ilb.lb_backend_address_pool
}
