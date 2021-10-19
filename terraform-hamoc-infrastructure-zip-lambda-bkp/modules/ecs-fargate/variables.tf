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

variable "idle_timeout" {
  type        = number
  description = "ALB Idle time out"
  default     = 60
}

variable "internal" {
  type        = bool
  description = "ALB internal or not"
  default     = false
}

variable "enable_deletion_protection" {
  type        = bool
  description = "ALB Deletion protection"
  default     = false
}

variable "enable_access_logs" {
  type        = bool
  description = "Enable access log"
  default     = true
}

variable "alb_security_groups" {
  type        = list(any)
  description = "ALB Security group ID"
}

variable "ecs_security_groups" {
  type        = list(any)
  description = "ECS Security group ID"
}

variable "tg_port" {
  type        = number
  description = "Target group port"
  default     = 80
}

variable "tg_protocol" {
  type        = string
  description = "Target group protocol"
  default     = "HTTP"
}

variable "target_type" {
  type        = string
  description = "Target type"
  default     = "ip"
}

variable "deregistration_delay" {
  type        = number
  description = "Target deregistration delay"
  default     = 300
}

variable "health_check" {
  type = list(object({
    enabled             = bool
    healthy_threshold   = number
    interval            = number
    protocol            = string
    matcher             = number
    timeout             = number
    path                = string
    unhealthy_threshold = number
  }))
  default = [{
    enabled             = true
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }]
}

variable "stickiness" {
  type = list(object({
    enabled         = bool
    cookie_duration = number
    type            = string

  }))
  default = [{
    enabled         = true
    cookie_duration = "86400"
    type            = "lb_cookie"
  }]
}

variable "certificate_arn" {
  type        = string
  description = "ACM Certificate ARN"
}

variable "alb_logs_bucket" {
  type        = string
  description = "ALB Logs S3 Bucket name"
  default     = "alb-logs"
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

variable "fargate-ecrname" {
  description = "ECR Name for fargate"
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

variable "cw_log_retention" {
  type        = number
  description = "CW Log group retention"
  default     = 60
}

variable "cluster-name" {
  description = "ECS Clustername"
}

variable "ecs-service" {
  description = "ECS Service name"
}

variable "taskdefinition" {
  description = "ECS Taskdefinition name"
}

variable "secrets" {
  type    = any
  default = null
}

variable "environment_variables" {
  type    = any
  default = null
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  description = "deployment minimum healthy percent"
  default     = 50
}

variable "deployment_maximum_percent" {
  type        = number
  description = "deployment maximum percent"
  default     = 200
}

variable "desired_count" {
  type        = number
  description = "ECS Tasks desired count"
  default     = 1
}

variable "container_port" {
  type        = number
  description = "Container port"
  default     = 80
}

variable "max_capacity" {
  type        = number
  description = "Maximum autoscale capacity"
  default     = 1
}

variable "min_capacity" {
  type        = number
  description = "Minimum tasks count"
  default     = 1
}

variable "memory_threshold" {
  type        = number
  description = "Memory Threshold"
  default     = 60
}

variable "cpu_threshold" {
  type        = number
  description = "CPU Threshold"
  default     = 60
}

variable "task_memory" {
  type        = number
  description = "Task Memory Reservation"
  default     = 512
}

variable "task_cpu" {
  type        = number
  description = "CPU Memory Reservation"
  default     = 256
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "alb_subnets" {
  description = "Public Subnet ID for ALB"
}

variable "ecs_subnets" {
  description = "Private Subnet ID for ECS"
}

variable "website-domain-main" {
  type        = string
  description = "Main website domain"
}

variable "ecs-domain-name" {
  type        = string
  description = "ECS Domain name"
}

#------------------------------------------

variable "alb_blacklist_ipv4-list" {
  type        = list(any)
  description = "ALB Blacklist IPV4 List in x.x.x.x/x format"
}

variable "alb_blacklist_ipv6-list" {
  type        = list(any)
  description = "ALB Blacklist IPV6 List in x:x:x:x:x:x:x:x:x/x format"
}

variable "managed_rules" {
  type = list(object({
    name            = string
    priority        = number
    override_action = string
    excluded_rules  = list(string)
  }))
  description = "List of Managed WAF rules."
  default = [
    {
      name            = "AWSManagedRulesCommonRuleSet",
      priority        = 10
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesAmazonIpReputationList",
      priority        = 20
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesKnownBadInputsRuleSet",
      priority        = 30
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesSQLiRuleSet",
      priority        = 40
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesLinuxRuleSet",
      priority        = 50
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesUnixRuleSet",
      priority        = 60
      override_action = "none"
      excluded_rules  = []
    }
  ]
}

#----------------------------------------------

##Data Resources

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_elb_service_account" "main" {}
