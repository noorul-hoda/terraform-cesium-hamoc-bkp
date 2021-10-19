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

variable "create" {
  description = "Whether to create the Cloudwatch log metric filter and metric alarms"
  type        = bool
  default     = true
}

variable "disabled_controls" {
  description = "List of IDs of disabled CIS controls"
  type        = list(string)
  default     = []
}

variable "namespace" {
  description = "The namespace where metric filter and metric alarm should be cleated"
  type        = string
  default     = "CISBenchmark"
}

variable "log_group_name" {
  description = "The name of the log group to associate the metric filter with"
  type        = string
  default     = ""
}

variable "alarm_actions" {
  description = "List of ARNs to put as Cloudwatch Alarms actions (eg, ARN of SNS topic)"
  type        = list(string)
  default     = []
}

variable "actions_enabled" {
  description = "Indicates whether or not actions should be executed during any changes to the alarm's state."
  type        = bool
  default     = true
}
