//tag defining
locals {
  prefix = var.project
  suffix = terraform.workspace
  common_tags = {
    Environment = terraform.workspace
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}