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

variable "website-domain-main" {
  type        = string
  description = "Main website domain"
}

variable "api-domain-name" {
  description = "API Domain name"
}

variable "acm_website_cert_arn" {
  description = "acm website arn"
}

variable "cognito-user-pool_arn" {
  description = "Cognito user pool arn"
}

variable "dataingestion_invoke_arn" {
  type        = string
  description = "Data ingestion invoke ARN"
}

variable "inforeq_invoke_arn" {
  type        = string
  description = "inforeq invoke ARN"
}

variable "searchengine_invoke_arn" {
  type        = string
  description = "searchengine invoke ARN"
}

variable "externalapi_invoke_arn" {
  type        = string
  description = "externalapi invoke ARN"
}

variable "accountManagement_invoke_arn" {
  type        = string
  description = "accountManagement invoke ARN"
}

variable "dataManagement_invoke_arn" {
  type        = string
  description = "dataManagement invoke ARN"
}

variable "userProfile_invoke_arn" {
  type        = string
  description = "userProfile invoke ARN"
}

variable "uploadtos3_invoke_arn" {
  type        = string
  description = "uploadtos3 invoke ARN"
}

variable "dataingestion_fn_name" {
  type        = string
  description = "Data ingestion function name"
}

variable "inforeq_fn_name" {
  type        = string
  description = "inforeq function name"
}

variable "searchengine_fn_name" {
  type        = string
  description = "searchengine function name"
}

variable "externalapi_fn_name" {
  type        = string
  description = "externalapi function name"
}

variable "accountManagement_fn_name" {
  type        = string
  description = "accountManagement function name"
}

variable "dataManagement_fn_name" {
  type        = string
  description = "dataManagement function name"
}

variable "userProfile_fn_name" {
  type        = string
  description = "userProfile function name"
}

variable "uploadtos3_fn_name" {
  type        = string
  description = "uploadtos3 function name"
}