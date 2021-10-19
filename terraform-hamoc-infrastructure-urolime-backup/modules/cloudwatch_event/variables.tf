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
  description = "CW Event rule name"
}

variable "cw_event_rule_is_enabled" {
  type        = bool
  description = "Whether the rule should be enabled."
  default     = true
}

variable "event_bus_name" {
  type        = string
  description = "event bus name"
  default     = "default"

}
variable "cw_event_rule_description" {
  type        = string
  description = "The description of the rule."
  default     = null
}

variable "cw_event_rule_pattern" {
  description = "Event pattern described a HCL map which will be encoded as JSON with jsonencode function. See full documentation of CloudWatch Events and Event Patterns for details. http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/CloudWatchEventsandEventPatterns.html"
}

variable "arn" {
  type        = string
  description = "ARN of CW Event Target"
  default     = null
}

variable "input_transformer" {
  description = "Input transformer"
  type        = any
  default     = {}
}