terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.42"
      configuration_aliases = [ aws, aws.acm-virginia ]
    }
  }
}