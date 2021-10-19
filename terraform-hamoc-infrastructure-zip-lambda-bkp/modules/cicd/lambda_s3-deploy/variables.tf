variable "region" {
  type        = string
  description = "default aws region to deploy the resources"
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

variable "web_bucket_name" {
  description = "Frontend S3 Bucket name"
}

variable "cf_distribution_id" {
  description = "Frontend cloudfront distribution ID"
}

variable "approval_sns_arn" {
  description = "Approval SNS ARN"
}

variable "codestar_bitbucket_arn" {
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

variable "api-domain-name" {
  description = "API Domain name"
}

variable "lambda_packages_bucket_name" {
  description = "Lambda Packages bucket name"
}

##Data Resources

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_kms_alias" "s3kmskey" {
  name = "alias/aws/s3"
}
