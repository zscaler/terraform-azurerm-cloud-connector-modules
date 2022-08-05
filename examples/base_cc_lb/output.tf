locals {

  testbedconfig = <<TB

1) Copy the SSH key to the bastion host
scp -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.bastion.public_ip}:/home/centos/.

2) SSH to the bastion host
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.bastion.public_ip}

3) SSH to the CC
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem zsroot@${module.cc-vm.private_ip[0]} -o "proxycommand ssh -W %h:%p -i ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.bastion.public_ip}"

All CC Management IPs. Replace private IP below with zsroot@"ip address" in ssh example command above.
${join("\n", module.cc-vm.private_ip)}

4) SSH to the server host
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.workload.private_ip[0]} -o "proxycommand ssh -W %h:%p -i ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.bastion.public_ip}"

All Workload IPs. Replace private IP below with centos@"ip address" in ssh example command above.
${join("\n", module.workload.private_ip)}


Resource Group: 
${module.network.resource_group_name}

All CC Primary Service IPs:
${join("\n", module.cc-vm.service_ip)}

LB IP: 
${module.cc-lb.lb_ip}

All NAT GW IPs:
${join("\n", module.network.public_ip_address)}

Bastion Public IP: 
${module.bastion.public_ip}


TB
}

output "testbedconfig" {
  value = local.testbedconfig
}

resource "local_file" "testbed" {
  content  = local.testbedconfig
  filename = "../testbed.txt"
}