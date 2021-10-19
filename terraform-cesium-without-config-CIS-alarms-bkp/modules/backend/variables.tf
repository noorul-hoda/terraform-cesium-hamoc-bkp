//AWS default Region
//AWS default profile configuration
//Default Environment name
//Default Project name
//Default owner
//List of lambda which are used in api integration in dev
//List of lambda which are used in api integration in prod
//A list of lambda functions VPC
//Lambda security group ID
//Private subnets ID
//Cognito user pool arn

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

variable "lambda_for_api" {
  description = "list of lambda which are used in api integration"
}

variable "lambda_list" {
  type        = list(any)
  description = "A list of lambda functions VPC"
}

variable "db-username" {
  type        = string
  sensitive   = true
  description = "Username for the RDS postgres instance"
}

variable "db-password" {
  type        = string
  sensitive   = true
  description = "Password for the RDS postgres instance"
}

variable "db-host-address" {
  type        = string
  description = "Address for the RDS postgres instance"
}

variable "website-domain-main" {
  type        = string
  description = "Main website domain"
}

variable "api-domain-name" {
  description = "API Domain name"
}

variable "ecs-domain-name" {
  description = "ECS Domain name"
}

##Used to get values from another modules.

variable "sg-lambda-id" {
  description = "Lambda security group ID"
}

variable "subnets_priv_id" {
  description = "Private subnets ID"
}

variable "cognito-user-pool_arn" {
  description = "Cognito user pool arn"
}

variable "ecs_alb_dns_name" {
  description = "ECS ALB DNS Name"
}

variable "acm-website-cert-arn" {
  description = "acm website arn"
}

variable "update-routine-bucket-id" {
  description = "update routine bucket id"
}

variable "sagemaker-bucket-id" {
  description = "sagemaker bucket id"
}

##Data Resources

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}