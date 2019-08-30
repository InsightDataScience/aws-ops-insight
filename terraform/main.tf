/* 

Main configuration file for Terraform

Terraform configuration files are written in the HashiCorp Congiuration Language (HCL).
For more information on HCL syntax, visit: 

https://www.terraform.io/docs/configuration/syntax.html

 */

# Specify that we're using AWS, using the aws_region variable
provider "aws" {
  region  = var.aws_region
  version = "~> 2.23.0"
}

/* 

Configuration to make a very simple sandbox VPC for a few instances

For more details and options on the AWS vpc module, visit:
https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.30.0

 */
module "sandbox_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.9.0"

  name = "${var.fellow_name}-vpc"

  cidr           = "10.0.0.0/26"
  azs            = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  public_subnets = ["10.0.0.0/26"]

  enable_dns_support   = true
  enable_dns_hostnames = true

  enable_s3_endpoint = true

  tags = {
    Owner       = var.fellow_name
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
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"

  name        = "open-to-all-sg"
  description = "Security group to make all ports publicly open...not secure at all"

  vpc_id              = module.sandbox_vpc.vpc_id
  ingress_cidr_blocks = ["10.0.0.0/26"]
  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_cidr_blocks = ["10.0.0.0/26"]
  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = {
    Owner       = var.fellow_name
    Environment = "dev"
    Terraform   = "true"
  }
}

/* 

Configuration for a simple EC2 cluster of 4 nodes, 
within our VPC and with our open sg assigned to them

For all the arguments and options, visit:
https://www.terraform.io/docs/providers/aws/r/instance.html

Note: You don't need the below resources for using the Pegasus tool
  
 */

# Configuration for a "master" instance
resource "aws_instance" "cluster_master" {
  ami           = var.amis[var.aws_region]
  instance_type = "m4.large"
  key_name      = var.keypair_name
  count         = 1

  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  vpc_security_group_ids      = [module.open_all_sg.this_security_group_id]
  subnet_id                   = module.sandbox_vpc.public_subnets[0]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 100
    volume_type = "standard"
  }

  tags = {
    Name        = "${var.cluster_name}-master-${count.index}"
    Owner       = var.fellow_name
    Environment = "dev"
    Terraform   = "true"
    HadoopRole  = "master"
    SparkRole   = "master"
  }
}

# Configuration for 3 "worker" elastic_ips_for_instances
resource "aws_instance" "cluster_workers" {
  ami           = var.amis[var.aws_region]
  instance_type = "m4.large"
  key_name      = var.keypair_name
  count         = 3

  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  vpc_security_group_ids      = [module.open_all_sg.this_security_group_id]
  subnet_id                   = module.sandbox_vpc.public_subnets[0]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 100
    volume_type = "standard"
  }

  tags = {
    Name        = "${var.cluster_name}-worker-${count.index}"
    Owner       = var.fellow_name
    Environment = "dev"
    Terraform   = "true"
    HadoopRole  = "worker"
    SparkRole   = "worker"
  }
}

# Configuration for an Elastic IP to add to nodes
resource "aws_eip" "elastic_ips_for_instances" {
  vpc = true
  instance = element(
    concat(
      aws_instance.cluster_master.*.id,
      aws_instance.cluster_workers.*.id,
    ),
    count.index,
  )
  count = length(aws_instance.cluster_master) + length(aws_instance.cluster_workers)
}

