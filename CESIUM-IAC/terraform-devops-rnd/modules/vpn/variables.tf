//AWS default Region
//AWS default profile configuration
//Default Environment name
//Default Project name
//Default owner
//cgw on-prem ip
//on-prem cidr block

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

variable "cgw-onprem-ip" {
  type        = string
  description = "Customer GW IP of On Prem Network"
}

variable "onprem-cidr-block" {
  type        = list(any)
  description = "On Prem Network CIDR Block"
}

##Used to get values from another modules.

variable "vpc-id" {
  description = "VPC ID"
}

variable "route_table_pub_id" {
  description = "Public Route Table ID"
}

variable "route_table_priv_id" {
  description = "Private Route Table ID"
}
