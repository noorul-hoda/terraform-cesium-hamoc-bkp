resource "aws_codebuild_project" "codebuild" {
  name                   = "${local.prefix}-${var.name}-${local.suffix}"
  build_timeout          = var.build_timeout
  description            = var.description
  encryption_key         = var.encryption_key
  service_role           = var.service_role_arn

  # Artifacts
  dynamic "artifacts" {
    for_each = [var.artifacts]
    content {
      type                   = lookup(artifacts.value, "type")
      name                   = lookup(artifacts.value, "name")
      packaging              = lookup(artifacts.value, "packaging")
    }
  }

  # Environment
  dynamic "environment" {
    for_each = var.cb-environment
    content {
      compute_type                = lookup(environment.value, "compute_type")
      image                       = lookup(environment.value, "image")
      type                        = lookup(environment.value, "type")
      image_pull_credentials_type = lookup(environment.value, "image_pull_credentials_type")
      privileged_mode             = lookup(environment.value, "privileged_mode")

      # Environment variables
      dynamic "environment_variable" {
      for_each = var.environment_variable
        content {
          name  = environment_variable.value.name
          value = environment_variable.value.value
          type  = environment_variable.value.type
        }
      }
    }
  }

  # Logs_config
  dynamic "logs_config" {
    for_each = length(var.logs_config) > 0 ? [""] : []
    content {
      dynamic "cloudwatch_logs" {
        for_each = contains(keys(var.logs_config), "cloudwatch_logs") ? { key = var.logs_config["cloudwatch_logs"] } : {}
        content {
          status      = lookup(cloudwatch_logs.value, "status", null)
          group_name  = lookup(cloudwatch_logs.value, "group_name", null)
          stream_name = lookup(cloudwatch_logs.value, "stream_name", null)
        }
      }
  }
  }

  # Source
  dynamic "source" {
    for_each = [var.cb-source]
    content {
      type                = lookup(source.value, "type")
      buildspec           = lookup(source.value, "buildspec", null)
      }
    }

  # VPC Config
  dynamic "vpc_config" {
    for_each = length(keys(var.vpc_config)) == 0 ? [] : [var.vpc_config]
    content {
      vpc_id             = lookup(vpc_config.value, "vpc_id", null)
      subnets            = lookup(vpc_config.value, "subnets", null)
      security_group_ids = lookup(vpc_config.value, "security_group_ids", null)
    }
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.name}-${local.suffix}" }
    )
  )
  
}