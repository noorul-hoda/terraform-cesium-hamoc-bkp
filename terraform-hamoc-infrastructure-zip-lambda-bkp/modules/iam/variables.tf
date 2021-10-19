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
