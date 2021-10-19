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
//Comment the backend block wrt to AWS Account and do terraform init --reconfigure

##Prod Block
terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "cesium-backend-tfstate-prod"
    key            = "state.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "cesium-tfstate-lock-prod"
    profile        = "cesium-tf-admin-prod"
  }
}

##QA Block
# terraform {
#   backend "s3" {
#     encrypt        = true
#     bucket         = "<project-name>-backend-tfstate-qa"
#     key            = "state.tfstate"
#     region         = "eu-west-2"
#     dynamodb_table = "<project-name>-tfstate-lock-qa"
#     profile        = "<project-name>-tf-admin-qa"
#   }
# }


##Dev Block
// terraform {
//   backend "s3" {
//     encrypt        = true
//     bucket         = "cesium-backend-tfstate-dev"
//     key            = "state.tfstate"
//     region         = "eu-west-2"
//     dynamodb_table = "cesium-tfstate-lock-dev"
//     profile        = "cesium-tf-admin-dev"
//   }
// }

##############################################################################################


##Block For Testing Purpose Only

# terraform {
#   backend "s3" {
#     encrypt        = true
#     bucket         = "tfstate-urolime-random-prod"
#     key            = "state.tfstate"
#     region         = "eu-west-2"
#     dynamodb_table = "rnd-remote-tf-state-locks-prod"
#     profile        = "prod"
#   }
# }