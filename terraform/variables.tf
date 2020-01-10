/* 

Terraform file to define which variables are used

This is NOT where you set the variables. Instead, they should be 
set at the command line, with .tfvars files, or with environment variables

 */

variable "aws_region" {
  description = "AWS region to launch servers. For NY,BOS,VA use us-east-1. For SF use us-west-2"
  default     = "Insert AWS Region here"
}

variable "keypair_name" {
  description = "The name of your pre-made key-pair in Amazon (e.g. david-IAM-keypair)"
}

variable "fellow_name" {
  description = "The name that will be tagged on your resources."
}

variable "amis" {
 type = map (string)
  default = {
    "us-east-1" = "ami-0b6b1f8f449568786"
    "us-west-2" = "ami-02c8040256f30fb45"
  }
}

variable "cluster_name" {
  description = "The name for your instances in your cluster"
  default     = "cluster"
}

/*	

Not using AWS credential variables since they're automatically detected 
from the environment variables

However, you could remove this and use a **properly** secured variable file
If you prefer to use a variable file, then you should NOT commit that file 
and should use a proper security measures (e.g. use .gitignore, restrict access)

It is also worth noting that Terraform stores state in plaintext, so should
be used in production with a remote backend that is encrypted (e.g. S3, Consul)

variable "aws_access_key" {
	description = "AWS access key (e.g. ABCDE1F2G3HIJKLMNOP )"	
}

variable "aws_secret_key" {
	description = "AWS secret key (e.g. 1abc2d34e/f5ghJKlmnopqSr678stUV/WXYZa12 )"	
}

 */
