//AWS default Region
//AWS default profile configuration
//Default Environment name
//Default Project name
//Default owner
//Backend/Frontend Repo name
//Frontend S3 Bucket name
//Frontend cloudfront distribution ID
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

##Used to get values from another modules.

variable "repo_name" {
  description = "Backend/Frontend Repo name"
}

variable "web-bucket-name" {
  description = "Frontend S3 Bucket name"
}

variable "cf-distribution_id" {
  description = "Frontend cloudfront distribution ID"
}

variable "approval_sns_arn" {
  description = "Approval SNS ARN"
}

variable "codestar-bitbucket-arn" {
  description = "codestar connection bitbucket arn"
}

variable "lambda_codebuild_loggroup" {
  description = "lambda Codebuild log group"
}

variable "frontend_codebuild_loggroup" {
  description = "frontend Codebuild log group"
}

variable "lambda_codebuild_loggroup_arn" {
  description = "lambda Codebuild log group"
}

variable "frontend_codebuild_loggroup_arn" {
  description = "frontend Codebuild log group"
}

variable "api-gw-invoke-url" {
  description = "API GW Invoke URL"
}

variable "api-domain-name" {
  description = "API Domain name"
}

##Data Resources

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_kms_alias" "s3kmskey" {
  name = "alias/aws/s3"
}