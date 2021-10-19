data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

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

data "template_file" "aws_config_sns_policy" {
  template = <<JSON
{
"Version": "2008-10-17",
"Id": "Policy_ID",
"Statement": [
  {
    "Sid": "AWSConfigSNSPolicy",
    "Effect": "Allow",
    "Principal": {
      "Service": "config.amazonaws.com"
    },
    "Action": "SNS:Publish",
      "Resource": "$${sns_resource_arn}"
    }
]
}
JSON

  vars = {
    sns_resource_arn = module.sns-config-alerts.sns_topic_arn
  }
}

data "template_file" "codepipeline-updates_sns_policy" {
  template = <<JSON
{
"Version": "2008-10-17",
"Id": "Policy_ID",
"Statement": [
  {
    "Sid": "AWSConfigSNSPolicy",
    "Effect": "Allow",
    "Principal": {
      "Service": "events.amazonaws.com"
    },
    "Action": "SNS:Publish",
      "Resource": "$${sns_resource_arn}"
    }
]
}
JSON

  vars = {
    sns_resource_arn = module.sns-codepipeline-updates.sns_topic_arn
  }
}

data "aws_ecr_repository" "hello-world" {
  name = "sample-hello-world"
}

