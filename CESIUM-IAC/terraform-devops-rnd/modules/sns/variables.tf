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

variable "name" {
  description = "The name of the SNS topic to create"
  type        = string
  default     = null
}

variable "display_name" {
  description = "The display name for the SNS topic"
  type        = string
  default     = null
}

variable "delivery_policy" {
  type        = string
  description = "The SNS delivery policy as JSON."
  default     = null
}

variable "sns_topic_policy_json" {
  type        = string
  description = "The fully-formed AWS policy as JSON"
  default     = ""
}

##Data Resources

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}