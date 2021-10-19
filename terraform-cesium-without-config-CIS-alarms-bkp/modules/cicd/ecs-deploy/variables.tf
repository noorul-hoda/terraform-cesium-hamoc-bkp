//AWS default Region
//AWS default profile configuration
//Default Environment name
//Default Project name
//Default owner
//ECS Repository Name
//Taskdefinition
//ECR Name for ecs tasks
//ECS Cluster Name
//ECS Service Name
//Cognito user pool arn
//Data to get current AWS Region
//Data to get account ID
//Data to get KMS id for S3 default KMS

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

variable "api-domain-name" {
  description = "API Domain name"
}

##Used to get values from another modules.

variable "ecs-repo_name" {
  description = "ECS Repository Name"
}

variable "taskdefinition" {
  description = "Taskdefinition"
}

variable "fargate-ecrname" {
  description = "ECR Name for ecs tasks"
}

variable "ecs_clustername" {
  description = "ECS Cluster Name"
}

variable "ecs_servicename" {
  description = "ECS Service Name"
}

variable "approval_sns_arn" {
  description = "Approval SNS ARN"
}

variable "codestar-bitbucket-arn" {
  description = "codestar connection bitbucket arn"
}

variable "ecs_codebuild_loggroup" {
  description = "ECS Codebuild log group"
}

variable "ecs_codebuild_loggroup_arn" {
  description = "ECS Codebuild log group arn"
}

##Data Resources

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_kms_alias" "s3kmskey" {
  name = "alias/aws/s3"
}