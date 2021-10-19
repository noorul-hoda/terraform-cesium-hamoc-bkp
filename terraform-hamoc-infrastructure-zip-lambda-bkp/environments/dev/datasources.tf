data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_ami" "ami-london" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

data "aws_kms_alias" "rds" {
  name = "alias/aws/rds"
}

data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

data "aws_kms_alias" "es" {
  name = "alias/aws/es"
}