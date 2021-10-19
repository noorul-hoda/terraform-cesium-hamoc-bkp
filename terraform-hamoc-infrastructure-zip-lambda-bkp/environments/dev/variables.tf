####################
## Default Variables
####################

variable "region" {
  type        = string
  description = "default aws region to deploy the resources"
}

variable "profile" {
  type        = string
  description = "AWS Profile"
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

####################
## VPC Variables
####################

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

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "bastion_allowed_range" {
  type        = list(any)
  description = "Bastion Host allowed IPs"
}
####################
## RDS Variables
####################

variable "db_instance_class" {
  type        = string
  default     = "db.t2.micro"
  description = "The instance class for the rds"
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

####################
## Neptune Variables
####################

variable "neptune_instance_class" {
  type        = string
  default     = "db.t3.medium"
  description = "The instance class for the neptune"
}

####################
## ES Variables
####################

variable "es_instance_type" {
  type        = string
  default     = "t3.small.elasticsearch"
  description = "The instance type for the elasticsearch"
}

########################
## Domain name Variables
########################

variable "website-domain-main" {
  type        = string
  description = "Main website domain"
}

variable "ecs-domain-name" {
  type        = string
  description = "ECS Domain name"
}

variable "api-domain-name" {
  type        = string
  description = "API GW Domain name"
}

########################
## Repo name Variables
########################

variable "ecs-repo_name" {
  description = "ECS Repo Name"
}

variable "repo_name" {
  description = "Frontend/Backend repo name"
}

################
##ECS Variables
################

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

#########################################
##IP Variables For whitelist and blacklist
#########################################

variable "alb_whitelist_ipv4-list" {
  type        = list(any)
  description = "The public ipv6 ips list to whitelist in ALB ECS SG"
}

variable "alb_whitelist_ipv6-list" {
  type        = list(any)
  description = "The public ipv6 ips list to whitelist in ALB ECS SG"
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

################
##VPN Variables
################

variable "vpn_enabled" {
  type        = bool
  description = "Enable VPN"
  default     = false
}

variable "cgw_onprem_ip" {
  type        = string
  description = "Customer GW IP of On Prem Network"
}

variable "onprem_cidr_block" {
  type        = list(any)
  description = "On Prem Network CIDR Block"
}




