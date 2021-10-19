//tag defining
locals {
  prefix = var.project
  suffix = var.environment
  common_tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}