
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
  description = "Name of the Elasticsearch Domain."
}

variable "subnet_ids" {
  description = "subnet ids"
}

variable "security_group_ids" {
  type        = list(any)
  description = "Security Group ID"
}

variable "elasticsearch_version" {
  description = "Version of Elasticsearch to deploy."
  default     = "7.10"
}

variable "instance_count" {
  description = "Number of instances in the cluster."
  default     = "1"
}

variable "instance_type" {
  description = "Instance type of data nodes in the cluster."
  default     = "t3.small.elasticsearch"
}

variable "enable_encrypt" {
  type        = bool
  description = "Enable encryption"
  default     = null
}

variable "kms_key_id" {
  type        = string
  description = "KMS Key id"
  default     = null
}

variable "ebs_enabled" {
  description = "Whether EBS volumes are attached to data nodes in the domain."
  default     = "true"
}

variable "volume_type" {
  description = "Type of EBS volumes attached to data nodes."
  default     = "gp2"
}

variable "volume_size" {
  description = "(Required if ebs_enabled is set to true.) Size of EBS volumes attached to data nodes (in GiB)."
  default     = "10"
}

variable "create-service-link-role" {
  type        = bool
  description = "Create service linked role"
  default     = true
}

variable "tls_security_policy" {
  description = "tls_security_policy"
  default     = "Policy-Min-TLS-1-2-2019-07"
}

variable "enable_logs" {
  type        = bool
  default     = true
  description = "enable logs"
}

variable "retention_in_days" {
  type        = number
  default     = 60
  description = "Days of retention of cloudwatch."
}

variable "log_publishing_index_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether log publishing option for INDEX_SLOW_LOGS is enabled or not."
}

variable "log_publishing_search_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether log publishing option for SEARCH_SLOW_LOGS is enabled or not."
}

variable "log_publishing_application_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether log publishing option for ES_APPLICATION_LOGS is enabled or not."
}

variable "enforce_https" {
  type        = bool
  default     = true
  description = "Whether or not to require HTTPS."
}

##Data Sources

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}
