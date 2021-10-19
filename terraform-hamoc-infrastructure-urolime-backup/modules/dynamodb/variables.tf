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
  description = "Table Name"
}

variable "billing_mode" {
  type        = string
  description = "Billing mode of dynamodb"
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  type        = string
  description = "DynamoDB table Hash Key"
}

variable "range_key" {
  type        = string
  default     = ""
  description = "DynamoDB table Range Key"
}

variable "read_capacity" {
  default     = null
  description = "DynamoDB read capacity"
}

variable "write_capacity" {
  default     = null
  description = "Dynamodb Write Capacity"
}

variable "ttl_attribute" {
  type        = string
  default     = "expires"
  description = "DynamoDB table TTL attribute"
}

variable "ttl_enabled" {
  type        = string
  default     = "true"
  description = "Enable/Disable DynamoDB table TTL attribute"
}

variable "dynamodb_attributes" {
  type = list(object({
    name = string
    type = string
  }))
  default     = []
  description = "Additional DynamoDB attributes in the form of a list of mapped values"
}

variable "global_secondary_index_map" {
  type = list(object({
    hash_key           = string
    name               = string
    non_key_attributes = list(string)
    projection_type    = string
    range_key          = string
    read_capacity      = number
    write_capacity     = number
  }))
  default     = []
  description = "Additional global secondary indexes in the form of a list of mapped values"
}

variable "local_secondary_index_map" {
  type = list(object({
    name               = string
    non_key_attributes = list(string)
    projection_type    = string
    range_key          = string
  }))
  default     = []
  description = "Additional local secondary indexes in the form of a list of mapped values"
}

variable "enable_point_in_time_recovery" {
  type        = string
  default     = "false"
  description = "Enable DynamoDB point in time recovery"
}

variable "enable_encryption" {
  type        = string
  default     = "true"
  description = "Enable DynamoDB server-side encryption"
}
