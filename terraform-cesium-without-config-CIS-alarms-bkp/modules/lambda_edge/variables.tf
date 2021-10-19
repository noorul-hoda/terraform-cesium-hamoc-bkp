
//AWS default Region
//AWS default profile configuration
//Default Environment name
//Default Project name
//Default owner
//Main website domain

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

variable "create_lambda_edge" {
  type        = bool
  description = "Create lambda edge"
  default     = true
}

variable "lambda-edge-name" {
  type        = string
  description = "Lambda edge name"
}

variable "create_iam_role" {
  type        = bool
  description = "Create IAM role"
  default     = true
}

variable "iam_role_arn" {
  type        = string
  description = "Custom IAM role ARN"
  default     = null
}

variable "lambda_edge_code_dir" {
  type        = string
  description = "lambda_edge code directory path"
}

variable "handler" {
  description = "Lambda Function entrypoint in your code"
  type        = string
  default     = ""
}

variable "runtime" {
  type        = string
  description = "Lambda runtime"
  default     = "nodejs14.x"
}
