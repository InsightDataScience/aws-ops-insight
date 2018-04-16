/* 

Main configuration file for Terraform

Terraform configuration files are written in the HashiCorp Congiuration Language (HCL).
For more information on HCL syntax, visit: 

https://www.terraform.io/docs/configuration/syntax.html

 */

# Specify that we're using AWS, using the aws_region variable
provider "aws" {
  region   = "${var.aws_region}"
  version  = "~> 1.14"
}

# read the availability zones for the current region
data "aws_availability_zones" "all" {}


/* 

Configuration to make a very simple sandbox VPC for a few instances

For more details and options on the AWS vpc module, visit:
https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.9.1

 */
module "sandbox_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.30.0"

  name = "${var.fellow_name}-vpc"

  cidr = "10.0.0.0/26"

  azs              = ["${data.aws_availability_zones.all.names}"]
  public_subnets   = ["10.0.0.0/28"]
  private_subnets  = ["10.0.0.16/28"]

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

Configuration for a security group within our configured VPC sandbox,
open to all ports for any networking protocol 

For more details and options on the AWS sg module, visit:
https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/1.9.0

Check out all the available sub-modules at:
https://github.com/terraform-aws-modules/terraform-aws-security-group/tree/master/modules

 */
module "open_all_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "open-to-all-sg"
  description = "Security group to make all ports publicly open...not secure at all"
  vpc_id      = "${module.sandbox_vpc.vpc_id}"

  ingress_cidr_blocks      = ["10.0.0.0/26"]
  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Owner       = "${var.fellow_name}"
    Environment = "dev"
    Terraform   = "true"
  }
}

/* 

Configuration for a simple EC2 cluster of 4 nodes, 
within our VPC and with our open sg assigned to them

For more details and options on the AWS EC2 module, visit:
https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/1.5.0

 */
module "simple_ec2_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name           = "${var.fellow_name}"
  instance_count = 4

  ami                    = "ami-4e79ed36"
  instance_type          = "t2.micro"
  key_name               = "david-IAM-keypair"
  monitoring             = true
  vpc_security_group_ids = ["${module.open_all_sg.this_security_group_id}"]
  subnet_id              = "${module.sandbox_vpc.public_subnets[0]}"
  
  associate_public_ip_address = true

  tags = {
    Owner       = "${var.fellow_name}"
    Environment = "dev"
    Terraform   = "true"
  }
}
