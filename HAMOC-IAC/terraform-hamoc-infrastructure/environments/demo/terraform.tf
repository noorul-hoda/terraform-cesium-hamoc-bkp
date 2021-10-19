//Specifying provider/terraform version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.42"
    }
  }

  required_version = "~> 0.15"
}

//provider "AWS"
provider "aws" {
  region  = var.region
  profile = var.profile

}

# N. virginia region to create the Amazon certificate
provider "aws" {
  region  = "us-east-1"
  alias   = "acm-virginia"
  profile = var.profile

}

##############################################################################################

//Using s3 bucket as remote state management
//terraform init --reconfigure

#Demo Block
terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "hamoc-backend-tfstate-demo"
    key            = "state.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "hamoc-tfstate-lock-demo"
    profile        = "hamoc-tf-admin-demo"
  }
}

##############################################################################################