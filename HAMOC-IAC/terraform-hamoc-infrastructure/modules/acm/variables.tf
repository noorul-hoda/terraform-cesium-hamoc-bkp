variable "region" {
  type        = string
  description = "Default aws region to deploy the resources"
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
  description = "Certificate tag name"
}

variable "hosted_zone_domain" {
  type        = string
  description = "Hosted zone domain"
}

variable "domain_name" {
  type        = string
  description = "Main website domain"
}

variable "subject_alternative_names" {
  type        = list(any)
  description = "SAN Domain"
}

##Data Sources

data "aws_route53_zone" "hosted-zone" {
  name         = var.hosted_zone_domain
  private_zone = false
}