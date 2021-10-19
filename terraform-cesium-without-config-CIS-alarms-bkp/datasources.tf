data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_kms_alias" "rds" {
  name = "alias/aws/rds"
}

data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

data "aws_kms_alias" "es" {
  name = "alias/aws/es"
}