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
  type = string
}

variable "role_arn" {
  type        = string
  description = "An existing IAM role"
  default     = ""
}


variable "artifact_store" {
  description = "Map to populate the artifact block"
  type        = map(any)
}

variable "encryption_key" {
  description = "Map to populate the artifact block"
  type        = map(any)
}

variable "stages" {
  description = "This list describes each stage of the build"
}
