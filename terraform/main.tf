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
https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.30.0

 */
module "sandbox_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.30.0"

  name = "${var.fellow_name}-vpc"

  cidr             = "10.0.0.0/26"
  azs              = ["${data.aws_availability_zones.all.names}"]
  public_subnets   = ["10.0.0.0/28"]

  enable_dns_support   = true
  enable_dns_hostnames = true

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
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.9.0"

  name        = "open-to-all-sg"
  description = "Security group to make all ports publicly open...not secure at all"
  
  vpc_id                   = "${module.sandbox_vpc.vpc_id}"
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

For all the arguments and options, visit:
https://www.terraform.io/docs/providers/aws/r/instance.html

 */

# Configuration for a "master" instance
resource "aws_instance" "cluster_master" {
    ami             = "${lookup(var.amis, var.aws_region)}"
    instance_type   = "t2.micro"
    key_name        = "${var.keypair_name}"
    count           = 1

    vpc_security_group_ids      = ["${module.open_all_sg.this_security_group_id}"]
    subnet_id                   = "${module.sandbox_vpc.public_subnets[0]}"
    associate_public_ip_address = true
    
    root_block_device {
        volume_size = 100
        volume_type = "standard"
    }

    tags {
      Name        = "${var.cluster_name}-master-${count.index}"
      Owner       = "${var.fellow_name}"
      Environment = "dev"
      Terraform   = "true"
      ClusterRole = "master"
    }

}

# Configuration for 3 "worker" instance
resource "aws_instance" "cluster_workers" {
    ami             = "${lookup(var.amis, var.aws_region)}"
    instance_type   = "t2.micro"
    key_name        = "${var.keypair_name}"
    count           = 3

    vpc_security_group_ids      = ["${module.open_all_sg.this_security_group_id}"]
    subnet_id                   = "${module.sandbox_vpc.public_subnets[0]}"
    associate_public_ip_address = true
    
    root_block_device {
        volume_size = 100
        volume_type = "standard"
    }

    tags {
      Name        = "${var.cluster_name}-worker-${count.index}"
      Owner       = "${var.fellow_name}"
      Environment = "dev"
      Terraform   = "true"
      ClusterRole = "worker"
    }

}

# Configuration for an Elastic IP to add to nodes
resource "aws_eip" "elastic_ips_for_instances" {
  vpc       = true
  instance  = "${element(concat(aws_instance.cluster_master.*.id, aws_instance.cluster_workers.*.id), count.index)}"
  count     = "${aws_instance.cluster_master.count + aws_instance.cluster_workers.count}"
}
