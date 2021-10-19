//AWS default Region
//AWS default profile configuration
//Default Environment name
//Default Project name
//Default owner
//WAF Variables
//ECR Name for fargate
//ECS Clustername
//ECS Service name
//ECS Taskdefinition name
//ipv4/v6 white/blacklist ip lists

variable "region" {
  type        = string
  description = "default aws region to deploy the resources"
}

variable "profile" {
  type        = string
  description = "Your different aws configuration profile to separate the aws account"
}

variable "environment" {
  type        = string
  description = "Application different environment like dev/qa/prod"
}

variable "project" {
  type        = string
  description = "Your project name"
}

variable "owner" {
  type        = string
  description = "Owner of the terraform modules"
}

#------------------------------------------
# WAFv2 variables
//variable "scope" {
//  type = string
//  description = "IP Set scope. CLOUDFRONT or REGIONAL"
//  default = "CLOUDFRONT"
//}
variable "whitelist_ips" {
  description = "List of embargoed IPs by type"
  type        = map(list(string))
  default = {
    "IPV4" = ["1.2.3.4/16"] #My ip addresses
    //    "IPv6" = []
  }
}

variable "managed_rules" {
  type = list(object({
    name            = string
    priority        = number
    override_action = string
    excluded_rules  = list(string)
  }))
  description = "List of Managed WAF rules."
  default = [
    {
      name            = "AWSManagedRulesCommonRuleSet",
      priority        = 10
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesAmazonIpReputationList",
      priority        = 20
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesKnownBadInputsRuleSet",
      priority        = 30
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesSQLiRuleSet",
      priority        = 40
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesLinuxRuleSet",
      priority        = 50
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesUnixRuleSet",
      priority        = 60
      override_action = "none"
      excluded_rules  = []
    }
  ]
}

#----------------------------------------------

variable "fargate-ecrname" {
  description = "ECR Name for fargate"
}

variable "cluster-name" {
  description = "ECS Clustername"
}

variable "ecs-service" {
  description = "ECS Service name"
}

variable "taskdefinition" {
  description = "ECS Taskdefinition name"
}

variable "alb_blacklist_ipv4-list" {
  type = list(any)
  description = "ALB Blacklist IPV4 List in x.x.x.x/x format"
}

variable "alb_blacklist_ipv6-list" {
  type = list(any)
  description = "ALB Blacklist IPV6 List in x:x:x:x:x:x:x:x:x/x format"  
}

variable "ecs-domain-name" {
  type = string
}

##Used to get values from another modules.

variable "sg-ecs-id" {
  description = "ECS Security Group"
}

variable "sg-alb-id" {
  description = "ECS ALB Security Group"
}

variable "subnets_pub_id" {
  description = "Public Subnet ID"
}

variable "subnets_priv_id" {
  description = "Private Subnet ID"
}

variable "vpc-id" {
  description = "VPC ID"
}

variable "rds-postgre-address-ssm_arn" {
  description = "RDS Postgres Address SSM ARN"
}

variable "rds-postgre-username-ssm_arn" {
  description = "RDS Postgres Username SSM ARN"
}

variable "rds-postgre-password-ssm_arn" {
  description = "RDS Postgres Password SSM ARN"
}

variable "website-domain-main" {
  type        = string
  description = "Main website domain"
}

##Data resources
data "aws_kms_alias" "s3" {
name = "alias/aws/s3"
}

##Data Resources

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_elb_service_account" "main" {}