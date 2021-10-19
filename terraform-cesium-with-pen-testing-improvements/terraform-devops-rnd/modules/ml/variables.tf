//AWS default Region
//AWS default profile configuration
//Default Environment name
//Default Project name
//Default owner
//ML Lambda list
//DB Username/Password/Address
//Values from another modules
//Data resources

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

variable "ml_lambda_list" {
  type        = list(any)
  description = "A list of lambda functions for ml"
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

variable "api-domain-name" {
  description = "API Domain name"
}

variable "ecs-domain-name" {
  description = "ECS Domain name"
}

##Used to get values from another modules.

variable "db-host-address" {
  type        = string
  description = "Address for the RDS postgres instance"
}

variable "sg-sagemaker-id" {
  type        = string
  description = "sagemaker security group id"
}

variable "sg-lambda-id" {
  description = "Lambda security group ID"
}

variable "subnets_priv_id" {
  description = "Private subnets ID"
}

variable "ecs_alb_dns_name" {
  description = "ECS ALB DNS Name"
}

variable "lambda-apigw-access-id" {
  description = "Lambda api gw access aws access key"
}

variable "lambda-apigw-access-secret" {
  description = "Lambda api gw access aws secret key"
}

variable "sagemaker-bucket-arn" {
  description = "sagemaker bucket arn"
}

variable "sagemaker-bucket-id" {
  description = "sagemaker bucket id"
}

variable "update-routine-bucket-id" {
  description = "update routine bucket id"
}

##Data Resources

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
