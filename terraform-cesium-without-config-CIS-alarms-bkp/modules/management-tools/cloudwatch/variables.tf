//AWS default Region
//AWS default profile configuration
//Default Environment name
//Default Project name
//Default owner
//RDS Identifier
//ECS ALB ARN Suffix
//ECS ALB Target group ARN Suffix
//ECS Clustername
//ECS Service name

variable "region" {
  type        = string
  description = "default aws region to deploy the resources"
}

variable "profile" {
  type        = string
  description = "Your different aws configuration profile to separate the aws account"
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

variable "include_global_service_events" {
  type        = bool
  default     = true
  description = "Include global service events"
}

variable "is_multi_region_trail" {
  type        = bool
  description = "Multi region trial enable"
  default     = true
}

variable "enable_log_file_validation" {
  type        = bool
  description = "Enable log file validation"
  default     = true
}

##Used to get values from another modules.

variable "db-host-identifier" {
  description = "RDS Identifier"
}

variable "ecs_alb_arn_suffix" {
  description = "ECS ALB ARN Suffix"
}

variable "ecs_alb_tg_arn_suffix" {
  description = "ECS ALB Target group ARN Suffix"
}

variable "ecs_servicename" {
  description = "ECS Service name"
}

variable "ecs_clustername" {
  description = "ECS Clustername"
}

variable "ec2-etl-instance-id" {
  description = "ec2 etl instance id"
}

variable "bastion-host-instance-id" {
  description = "bastion host instance id"
}

variable "sts-vpn-id" {
  description = "Site to Site VPN ID"
}

##Data Resources

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_availability_zones" "available" {}
