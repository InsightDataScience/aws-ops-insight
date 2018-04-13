# Configuration for security groups

module "security-group_ssh" {
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

#######
# HTTP
#######
#module "http_sg" {
#  source = "../../modules/http-80"
#
#  name        = "http-sg"
#  description = "Security group with HTTP ports open for everybody (IPv4 CIDR), egress ports are all world open"
#  vpc_id      = "${data.aws_vpc.default.id}"
#
#  ingress_cidr_blocks = ["0.0.0.0/0"]
#}

