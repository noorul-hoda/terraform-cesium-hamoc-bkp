//AWS default Region
//AWS default profile configuration
//Default Environment name
//Default Project name
//Default owner
//Username for the RDS postgres instance
//Password for the RDS postgres instance
//RDS DB instance class
//Private Subnets ID
//RDS Security Group ID

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

variable "db-username-etl" {
  type        = string
  sensitive   = true
  description = "Username for the RDS postgres instance"
}

variable "db-password-etl" {
  type        = string
  sensitive   = true
  description = "Password for the RDS postgres instance"
}

variable "db_instance_class" {
  type        = string
  description = "The instance class for the rds"
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

##Used to get data from another modules

variable "subnets_priv_id" {
  description = "Private Subnets ID"
}

variable "sg-rds-id" {
  description = "RDS Security Group ID"
}

##Data resources

data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

##Sagemaker bucket policy
variable "ml-sagemaker-role-arn" {
  description = "ml sagemaker role arn"
}

variable "ml_lambda_role-arn" {
  description = "ml lambda function role arn"
}