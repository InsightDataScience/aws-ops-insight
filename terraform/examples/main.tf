/* 

Main configuration file for Terraform

Terraform configuration files are written in the HashiCorp Congiuration Language (HCL).
For more information on HCL syntax, visit: 

https://www.terraform.io/docs/configuration/syntax.html

 */

provider "aws" {
    region   = "${var.aws_region}"
    version  = "~> 1.14"
}


/* 

AWS VPC module For more details and options, visit:
https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.9.1

 */
module "sandbox_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.30.0"

  name = "${var.fellow_name}-vpc"

  cidr = "10.0.0.0/26"

  azs              = ["us-west-2a", "us-west-2b", "us-west-2c", "us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets   = ["10.0.0.0/28"]
  private_subnets  = ["10.0.1.0/28"]

  enable_dns_support   = true
  enable_dns_hostnames = true

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_s3_endpoint = true

  tags = {
    Owner       = "${var.fellow_name}"
    Environment = "dev"
    Terraform   = "true"
  }
}  


/* 

Configuration for security groups. For more details and options, see the module page below
https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/1.9.0

Check out all the available sub-modules at:
https://github.com/terraform-aws-modules/terraform-aws-security-group/tree/master/modules

 */

# Security Group sub-module for the SSH protocol
module "open-ssh-sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "1.20.0"

  vpc_id      = "${module.sandbox_vpc.vpc_id}"
  name        = "ssh-open-sg"
  description = "Security group for SSH, open from/to all IPs"
  
  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Owner       = "${var.fellow_name}"
    Environment = "dev"
    Terraform   = "true"
  }
}