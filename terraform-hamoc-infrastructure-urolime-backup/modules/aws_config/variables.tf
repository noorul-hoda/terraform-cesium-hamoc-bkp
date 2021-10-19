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

variable "enable_config_recorder" {
  description = "Enables configuring the AWS Config recorder resources in this module."
  type        = bool
  default     = true
}

variable "config_name" {
  type        = string
  description = "config name"
  default     = "config"
}

variable "include_global_resource_types" {
  description = "Specifies whether AWS Config includes all supported types of global resources with the resources that it records."
  type        = bool
  default     = true
}

variable "create_iam_role" {
  type        = bool
  description = "Create IAM Role"
  default     = true
}

variable "iam_role_arn" {
  type        = string
  description = "IAM role arn"
  default     = null
}

variable "config_logs_bucket" {
  description = "The S3 bucket for AWS Config logs. If you have set enable_config_recorder to false then this can be an empty string."
  type        = string
}

variable "config_logs_prefix" {
  description = "The S3 prefix for AWS Config logs."
  type        = string
  default     = "config"
}

variable "config_sns_topic_arn" {
  description = "An SNS topic to stream configuration changes and notifications to."
  type        = string
  default     = null
}

variable "managed_rules" {
  description = <<-DOC
    A list of AWS Managed Rules that should be enabled on the account. 
    See the following for a list of possible rules to enable:
    https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html
  DOC
  type = map(object({
    description      = string
    identifier       = string
    input_parameters = any
    tags             = map(string)
    enabled          = bool
  }))
  default = {}
}

##Data Resources

data "aws_caller_identity" "current" {}