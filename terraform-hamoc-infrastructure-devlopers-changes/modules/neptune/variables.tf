
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
  description = "Name of the neptune resources."
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "subnet_ids" {
  description = "Subnets ID"
}

variable "vpc_security_group_ids" {
  type        = list(any)
  description = "Security Group ID"
}

variable "cluster_engine" {
  description = "The name of the database engine to be used for this Neptune cluster."
  default     = "neptune"
}

variable "cluster_iam_database_authentication_enabled" {
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled."
  default     = true
}

variable "cluster_apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window."
  default     = true
}

variable "cluster_skip_final_snapshot" {
  description = "Determines whether a final Neptune snapshot is created before the Neptune cluster is deleted."
  default     = true
}

variable "cluster_backup_retention_period" {
  description = "The days to retain backups for."
  default     = 1
}

variable "cluster_preferred_backup_window" {
  description = " The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter. Time in UTC."
  default     = "01:00-02:00"
}

variable "cluster_preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC)."
  default     = "sun:02:00-sun:02:30"
}

variable "instance_count" {
  description = "Number of Neptune instances to launch."
  default     = 1
}

variable "instance_engine" {
  description = "The name of the database engine to be used for this Neptune cluster."
  default     = "neptune"
}

variable "instance_class" {
  description = "The instance class to use."
  default     = "db.t3.medium"
}

variable "instance_apply_immediately" {
  description = "Specifies whether any instance modifications are applied immediately, or during the next maintenance window."
  default     = true
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN for the KMS encryption key if one is set to the neptune cluster."
  default     = null
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible."
  default     = false
}

variable "parameter" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

#Data sources

data "aws_availability_zones" "available" {
  state = "available"
}