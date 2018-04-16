/* 

Terraform file to define which variables are used

This is NOT where you set the variables. Instead, they should be 
set at the command line, with .tfvars files, or with environment variables

 */

/*	Not using AWS creds since they're automatically detected from the command line

variable "aws_access_key" {
	description = "AWS access key (e.g. ABCDE1F2G3HIJKLMNOP )"	
}

variable "aws_secret_key" {
	description = "AWS secret key (e.g. 1abc2d34e/f5ghJKlmnopqSr678stUV/WXYZa12 )"	
}

 */ 

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

variable "fellow_name" {
  description = "Enter your name."
}