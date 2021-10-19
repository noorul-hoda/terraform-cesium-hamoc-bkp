//AWS default Region
//AWS default profile configuration
//Default Environment name
//Default Project name
//Default owner
//Main website domain
//Cognito user attributes
//Cognito SMS configuration
//ACM Cert ARN
//wafv2 webacl arn
//Lambda Edge function Qualified ARN

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

variable "website-domain-main" {
  type        = string
  description = "Main website domain"
}

# Cognito variables

variable "user_attributes" {
  type        = set(string)
  description = "(Optional) The attributes to be auto-verified. Possible values: 'email', 'phone_number'."
  default = [
    "email"
  ]
}

# variable "mfa_configuration" {
#   type        = string
#   description = "Multi-Factor Authentication (MFA) configuration for the User Pool. Valid values: 'ON', 'OFF' or 'OPTIONAL'. 'ON' and 'OPTIONAL' require at least one of 'sms_configuration' or 'software_token_mfa_configuration' to be configured."
# }

variable "sms_configuration" {
  description = "(Optional) The `sms_configuration` with the `external_id` parameter used in iam role trust relationships and the `sns_caller_arn` parameter to set he arn of the amazon sns caller. this is usually the iam role that you've given cognito permission to assume."
  type = object({
    # The external ID used in IAM role trust relationships. For more information about using external IDs, see https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html
    external_id = string
    # The ARN of the Amazon SNS caller. This is usually the IAM role that you've given Cognito permission to assume.
    sns_caller_arn = string
  })
  default = null
}

##Used to get values from another modules.

variable "wafv2-web-acl-arn" {
  description = "wafv2 webacl arn"
}

# variable "lambda-edge_qualified_arn" {
#   description = "Lambda Edge function Qualified ARN"
# }

variable "lambda_function_association" {
  type = list(object({
    event_type   = string
    lambda_arn   = string
    include_body = bool
  }))
  default = []
}

##Data Resources
data "aws_canonical_user_id" "current_user" {}
