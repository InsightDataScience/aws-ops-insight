# Configuration for security groups

# For more details and options, see the module page below
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/1.9.0


# General module for configuring security groups
module "totally_opened_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "open_to_all"
  description = "Security group for to make all ports publicly open...not secure at all"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks      = ["10.0.0.0/26"]
  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}


# Check out all the sub-modules at the below URL
# https://github.com/terraform-aws-modules/terraform-aws-security-group/tree/master/modules

# Sub-module for configuring an SSH security group
module "security-group_ssh_open" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "1.20.0"

  vpc_id      = "${module.vpc.vpc_id}"
  name        = "ssh-open-sg"
  description = "SSH open from and to all IPs"
  
  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Owner       = "${var.fellow_name}"
    Environment = "dev"
    Terraform   = "true"
  }
}



