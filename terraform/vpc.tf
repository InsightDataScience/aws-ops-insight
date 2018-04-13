# Main file to configure the AWS VPC

provider "aws" {
    region = "${var.aws_region}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.30.0"

  name = "${var.fellow_name}-vpc"

  cidr = "10.0.0.0/26"

  azs              = ["us-west-2a", "us-west-2b", "us-west-2c", "us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets   = ["10.0.0.0/28"]
  private_subnets  = ["10.0.0.16/28"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_s3_endpoint = true

  tags = {
    Owner       = "${var.fellow_name}"
    Environment = "dev"
    Terraform   = "true"
  }
}  
