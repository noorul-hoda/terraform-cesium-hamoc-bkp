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
  description = "Name"
}

variable "image_tag_mutability" {
  type        = string
  description = "ECR Image Tag Mutability"
  default     = "MUTABLE"
}

variable "scan_images_on_push" {
  type        = bool
  description = "scan_images_on_push"
  default     = true
}

variable "expire_image_count" {
  type        = number
  description = "ECR Expire image count"
  default     = 1000
}

##Data Resources

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
