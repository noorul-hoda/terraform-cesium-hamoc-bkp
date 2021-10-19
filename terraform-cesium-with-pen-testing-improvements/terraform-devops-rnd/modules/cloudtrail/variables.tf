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

variable "trail_name" {
  type        = string
  description = "Trails name"
  default     = "trails"
}

variable "event_selector" {
  type = list(object({
    include_management_events = bool
    read_write_type           = string

    data_resource = list(object({
      type   = string
      values = list(string)
    }))
  }))

  description = "Specifies an event selector for enabling data event logging. See: https://www.terraform.io/docs/providers/aws/r/cloudtrail.html for details on this variable"
  default     = []
}

variable "log_retention_days" {
  type        = number
  description = "Cloudwatch log retention days"
  default     = 60
}

variable "cloudwatch_log_group_name" {
  type        = string
  description = "Cloudwatch log group name"
  default     = "cloudtrail-loggroup"
}

variable "cloudtrail_bucketname" {
  type        = string
  description = "Cloudtrail S3 Bucket name"
  default     = "cloudtrails"
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

variable "iam_role_name" {
  type        = string
  description = "IAM Role name"
  default     = "cloudtrail_events_role"

}

variable "key_deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource, must be 7-30 days.  Default 30 days."
  default     = 30
  type        = string
}

variable "include_global_service_events" {
  type        = bool
  default     = false
  description = "Include global service events"
}

variable "is_multi_region_trail" {
  type        = bool
  description = "Multi region trial enable"
  default     = false
}

variable "enable_log_file_validation" {
  type        = bool
  description = "Enable log file validation"
  default     = false
}

variable "logging" {
  description = "Map containing access bucket logging configuration."
  type        = map(string)
  default     = {}
}

##Data Resources

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_availability_zones" "available" {}
