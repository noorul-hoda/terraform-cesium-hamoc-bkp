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

variable "website-domain-main" {
  type        = string
  description = "Main website domain"
}

variable "cognito_pool_name" {
  type        = string
  description = "cognito pool name"
  default     = "cogito-user-pool"
}

variable "cognito_identity_pool_name" {
  type        = string
  description = "Cognito identity pool name"
  default     = "cognito-identity-pool"
}

variable "user_attributes" {
  type        = set(string)
  description = "(Optional) The attributes to be auto-verified. Possible values: 'email', 'phone_number'."
  default = [
    "email"
  ]
}

variable "SMS_Role" {
  type        = string
  description = "SMS Role name"
  default     = "SMS-Role"
}

variable "SMS_Role_Policy" {
  type        = string
  description = "SMS Role policy name"
  default     = "SMS-Role-Policy"
}

variable "cognito_role" {
  description = "cognito role name"
  default     = "cognito-role"
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

variable "acm_website_cert_arn" {
  description = "ACM ARN"
}
