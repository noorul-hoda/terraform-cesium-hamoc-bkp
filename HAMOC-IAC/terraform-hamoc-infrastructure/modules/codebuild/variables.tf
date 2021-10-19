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
  type        = string
  description = "codebuild name"
}

variable "description" {
  description = "A short description of the project."
  type        = string
  default     = null
}

variable "build_timeout" {
  description = "How long in minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed.The default is 60 minutes."
  type        = number
  default     = 60
}

variable "encryption_key" {
  description = "The AWS Key Management Service (AWS KMS) customer master key (CMK) to be used for encrypting the build project's build output artifacts."
  type        = string
  default     = null
}

variable "service_role_arn" {
  description = "A predefined service role to be used"
  type        = string
  default     = null
}

variable "artifacts" {
  type        = any
  default     = {}
  description = "Codebuild artifacts details"
}

variable "cb-environment" {
  type        = any
  description = "Codebuild environment"
  default = [{
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = "true"
    image_pull_credentials_type = "CODEBUILD"
  }]
}

variable "environment_variable" {
  type = list(object(
    {
      name  = string
      value = string
      type  = string
  }))

  default = []

  description = "A list of maps, that contain the keys 'name', 'value', and 'type' to be used as additional environment variables for the build. Valid types are 'PLAINTEXT', 'PARAMETER_STORE', or 'SECRETS_MANAGER'"
}

variable "logs_config" {
  type        = any
  default     = {}
  description = "Configuration for the builds to store log data to CloudWatch or S3."
}

variable "cb-source" {
  type        = any
  default     = {}
  description = "Codebuild source details"
}

variable "vpc_config" {
  description = "Configuration for the builds to run inside a VPC."
  type        = any
  default     = {}
}
