
module "ec2_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name           = "${var.fellow_name}-"
  instance_count = 4

  ami                    = "ami-4e79ed36"
  instance_type          = "t2.micro"
  key_name               = "david-IAM-keypair"
  monitoring             = true
  vpc_security_group_ids = ["${module.totally_opened_sg.totally_opened_sg_id}"]
  subnet_id              = "${module.vpc.public_subnets[0]}"
  
  associate_public_ip_address = true

  tags = {
    Owner       = "${var.fellow_name}"
    Environment = "dev"
    Terraform   = "true"
  }
}

output "test_output" {
  value = "${module.totally_opened_sg.totally_opened_sg_name}"
}