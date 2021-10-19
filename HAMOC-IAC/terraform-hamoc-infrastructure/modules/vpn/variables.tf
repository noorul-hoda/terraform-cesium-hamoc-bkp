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

variable "enabled" {
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

variable "vpc_id" {
  description = "VPC ID"
}

variable "route_table_pub_id" {
  description = "Public Route Table ID"
}

variable "route_table_priv_id" {
  description = "Private Route Table ID"
}
