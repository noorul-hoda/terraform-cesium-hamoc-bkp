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

variable "myip" {
  type        = string
  description = "Your machine public ip to be whitelisted for ssh connectivity"
}

variable "instance-type" {
  type        = string
  description = "The type of instance to start"
}

//VPC parameters"
variable "cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "pub-subnet" {
  type        = list(any)
  description = "A list of public subnets inside the VPC"
}

variable "priv-subnet" {
  type        = list(any)
  description = "A list of private subnets inside the VPC"
}

variable "website-domain-main" {
  type        = string
  description = "Main website domain"
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
  default     = "db.t2.micro"
  description = "The instance class for the rds"
}

variable "repo_name" {}

variable "lambda_list" {}

variable "lambda_for_api" {
  description = "list of lambda which are used in api integration"
}

variable "fargate-ecrname" {
  description = "Fargate ECR name"
}

variable "cluster-name" {
  description = "ECS Cluster name"
}

variable "ecs-service" {
  description = "ECS Service name"
}

variable "taskdefinition" {
  description = "ECS Taskdefinition name"
}

variable "ecs-repo_name" {
  description = "ECS Repo Name"
}

variable "ecs-domain-name" {
  type = string
}

variable "alb_blacklist_ipv4-list" {
  type        = list(any)
  description = "ALB Blacklist IPV4 List in x.x.x.x/x format"
}

variable "alb_blacklist_ipv6-list" {
  type        = list(any)
  description = "ALB Blacklist IPV6 List in x.x.x.x.x.x.x.x/x format"
}

variable "cf_whitelist_ipv4-list" {
  type        = list(any)
  description = "Cloudfront Whitelist IPV4 List in x.x.x.x/x format"
}

variable "cf_whitelist_ipv6-list" {
  type        = list(any)
  description = "Cloudfront Whitelist IPV6 List in x.x.x.x.x.x.x.x/x format"
}

variable "cf_blacklist_ipv4-list" {
  type        = list(any)
  description = "Cloudfront Blacklist IPV4 List in x.x.x.x/x format"
}

variable "cf_blacklist_ipv6-list" {
  type        = list(any)
  description = "Cloudfront Blacklist IPV6 List in x.x.x.x.x.x.x.x/x format"
}

variable "alb_whitelist_ipv4-list" {
  type        = list(any)
  description = "The public ipv6 ips list to whitelist in ALB ECS SG"
}

variable "alb_whitelist_ipv6-list" {
  type        = list(any)
  description = "The public ipv6 ips list to whitelist in ALB ECS SG"
}

variable "cgw-onprem-ip" {
  type        = string
  description = "Customer GW IP of On Prem Network"
}

variable "onprem-cidr-block" {
  type        = list(any)
  description = "On Prem Network CIDR Block"
}

variable "ml_lambda_list" {
  type        = list(any)
  description = "A list of lambda functions for ml"
}

variable "ml_lambda_repo_name" {
  type        = string
  description = "ml lambda functions repository"
}

variable "api-domain-name" {
  type        = string
  description = "API Domain name"
}