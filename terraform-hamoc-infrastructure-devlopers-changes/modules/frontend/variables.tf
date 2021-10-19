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

variable "cf-distribution" {
  type        = string
  description = "CF Distribution name"
  default     = "cf-distribution"
}

variable "website-domain-main" {
  type        = string
  description = "Main website domain"
}

variable "cf-logs-bucket" {
  type        = string
  description = "Cloudfront logs bucket"
  default     = "cf-standard-logs"
}

variable "lifecycle_rule_enable" {
  type        = bool
  description = "ALB Logs S3 Bucket Lifecylce rule enable or not"
  default     = true
}

variable "transition_days" {
  type        = number
  description = "Number of days for s3 transition lifecycle"
  default     = 30
}

variable "transition_storage_class" {
  type        = string
  description = "S3 Storage class for transition"
  default     = "STANDARD_IA"
}

variable "expiry_days" {
  type        = number
  description = "Number of days for s3 expiry lifecycle"
  default     = 60
}

variable "web-bucket" {
  type        = string
  description = "Web frontend bucket"
}

variable "default_root_object" {
  type        = string
  description = "Default Cloudfront root object"
  default     = "index.html"
}

variable "cf_enabled" {
  type        = bool
  description = "Enable or disable Cloudfront"
  default     = true
}

variable "lambda_function_association" {
  type = list(object({
    event_type   = string
    lambda_arn   = string
    include_body = bool
  }))
  default = []
}

variable "wafv2_web_acl_arn" {
  description = "wafv2 webacl arn"
}

variable "acm_website_cert_arn" {
  description = "ACM ARN"
}

#Data Resources

data "aws_canonical_user_id" "current_user" {}
