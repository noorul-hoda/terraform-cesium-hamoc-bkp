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

variable "compute_bucket_name" {
  type        = string
  description = "Compute bucket name"
}

variable "landing_bucket_name" {
  type        = string
  description = "Landing bucket name"
}

variable "raw_bucket_name" {
  type        = string
  description = "Raw bucket name"
}

variable "analytics_bucket_name" {
  type        = string
  description = "Analytics bucket name"
}

variable "ecs_pipeline_artifacts_id" {
  type        = string
  description = "ECS Pipeline Artifacts S3 bucket ID"
}

variable "ecs_codebuild_loggroup_arn" {
  type        = string
  description = "ECS Codebuild Log group ARN"
}

variable "frontend_codebuild_loggroup_arn" {
  type        = string
  description = "Frontend Codebuild Log group ARN"
}

variable "frontend_backend_pipeline_artifacts_id" {
  type        = string
  description = "Frontend Backend Pipeline Artifacts S3 bucket ID"
}

variable "lambda_codebuild_loggroup_arn" {
  type        = string
  description = "Lambda Codebuild Log group ARN"
}

# variable "lambda_packages_bucket_name" {
#   type = string
#   description = "Lambda Packages Bucket name"
# }

variable "web_bucket_name" {
  type        = string
  description = "Web frontend Bucket name"
}