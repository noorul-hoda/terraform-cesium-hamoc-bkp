//AWS default Region
//AWS default profile configuration
//Default Environment name
//Default Project name
//Default owner
//Default ec2 instance count
//My IP address
//Default Private and public key for ec2 instances
//The CIDR block for the VPC
//A list of public subnets inside the VPC
//A list of private subnets inside the VPC

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
  description = "The typeof instance to start"
}

variable "instance-type-etl" {
  type        = string
  description = "The typeof instance to start"
}

variable "alb_whitelist_ipv4-list" {
  type        = list(any)
  description = "The public ipv6 ips list to whitelist in ALB ECS SG"
}

variable "alb_whitelist_ipv6-list" {
  type        = list(any)
  description = "The public ipv6 ips list to whitelist in ALB ECS SG"
}

//VPC parameters

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

variable "bulk-load-s3_arn" {
  description = "bulk load s3 bucket arn"
}


variable "enable_flow_log" {
  description = "Whether or not to enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "vpc_flow_log_permissions_boundary" {
  description = "The ARN of the Permissions Boundary for the VPC Flow Log IAM Role"
  type        = string
  default     = null
}

variable "create_flow_log_cloudwatch_log_group" {
  description = "Whether to create CloudWatch log group for VPC Flow Logs"
  type        = bool
  default     = true
}

variable "create_flow_log_cloudwatch_iam_role" {
  description = "Whether to create IAM role for VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_log_traffic_type" {
  description = "The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL."
  type        = string
  default     = "ALL"
}

variable "flow_log_destination_type" {
  description = "Type of flow log destination. Can be s3 or cloud-watch-logs."
  type        = string
  default     = "cloud-watch-logs"
}

variable "flow_log_log_format" {
  description = "The fields to include in the flow log record, in the order in which they should appear."
  type        = string
  default     = null
}

variable "flow_log_destination_arn" {
  description = "The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket the appropriate permissions need to be set on that bucket's policy. When create_flow_log_cloudwatch_log_group is set to false this argument must be provided."
  type        = string
  default     = ""
}

variable "flow_log_cloudwatch_iam_role_arn" {
  description = "The ARN for the IAM role that's used to post flow logs to a CloudWatch Logs log group. When flow_log_destination_arn is set to ARN of Cloudwatch Logs, this argument needs to be provided."
  type        = string
  default     = ""
}

variable "flow_log_cloudwatch_log_group_name_prefix" {
  description = "Specifies the name prefix of CloudWatch Log Group for VPC flow logs."
  type        = string
  default     = "/aws/vpc-flow-log/"
}

variable "flow_log_cloudwatch_log_group_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group for VPC flow logs."
  type        = number
  default     = 60
}

variable "flow_log_cloudwatch_log_group_kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data for VPC flow logs."
  type        = string
  default     = null
}

variable "flow_log_max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds."
  type        = number
  default     = 600
}

##Data Resources

data "aws_availability_zones" "available" {}
