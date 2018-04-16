/* 

Output file to highlight customized outputs that are useful 
(compared to the hundreds of attributes Terraform stores)

To see the output after the apply, use the command: "terraform output"

 */


#Outputs for VPC module: 

# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.sandbox_vpc.vpc_id}"
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = ["${module.sandbox_vpc.private_subnets}"]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${module.sandbox_vpc.public_subnets}"]
}

# NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = ["${module.sandbox_vpc.nat_public_ips}"]
}


# Outputs for the Security Group module
output "open_sg_id" {
  description = "The ID of the security group"
  value       = "${module.open_all_sg.this_security_group_id}"
}

output "open_sg_name" {
  description = "The name of the security group"
  value       = "${module.open_all_sg.this_security_group_name}"
}

