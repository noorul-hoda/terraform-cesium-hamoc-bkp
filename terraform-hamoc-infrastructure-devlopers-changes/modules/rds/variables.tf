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

variable "rds_name" {
  type        = string
  description = "RDS Name"
}

variable "subnet_ids" {
  description = "Subnets ID"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "vpc_security_group_ids" {
  type        = list(any)
  description = "Security Group ID"
}

variable "db-username" {
  type        = string
  sensitive   = true
  description = "Username for the RDS postgres instance"
}

variable "db-password" {
  type        = string
  sensitive   = true
  description = "Password for the RDS postgres instance"
}

variable "db_instance_class" {
  type        = string
  description = "The instance class for the rds"
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = string
  default     = null
}

variable "max_allocated_storage" {
  description = "Specifies the value for Storage Autoscaling"
  type        = number
  default     = 0
}

variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'gp2' if not."
  type        = string
  default     = null
}

variable "engine" {
  description = "The database engine to use"
  type        = string
  default     = ""
}

variable "engine_version" {
  description = "The engine version to use"
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from final_snapshot_identifier"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "The Availability Zone of the RDS instance"
  type        = string
  default     = null
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The days to retain backups for rds"
  type        = number
  default     = null
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. If creating an encrypted replica, set this to the destination KMS ARN. If storage_encrypted is set to true and kms_key_id is not specified the default KMS key created in your account will be used"
  type        = string
  default     = null
}

variable "create_event_subscription" {
  description = "Enable event subscription"
  type        = bool
  default     = true
}

variable "sns_topic" {
  type        = string
  description = "sns topic arn for event subscription"
  default     = ""
}

variable "source_type" {
  type        = string
  description = "Source type for event subscription"
  default     = ""
}

variable "source_ids" {
  type        = list(any)
  description = "Source ids for event subscription"
  default     = []
}

variable "event_categories" {
  type        = list(any)
  description = "Event categories for event subscription"
  default     = []
}
