data "archive_file" "dummy" {
  type        = "zip"
  output_path = "${path.module}/dummy.zip"

  source {
    content  = "hello"
    filename = "dummy.text"
  }
}

resource "aws_lambda_function" "lambda" {
  function_name                  = "${local.prefix}-${var.function_name}-${local.suffix}"
  description                    = var.description
  role                           = var.lambda_role
  handler                        = var.package_type != "Zip" ? null : var.handler
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  runtime                        = var.package_type != "Zip" ? null : var.runtime
  layers                         = var.layers
  timeout                        = var.timeout
  publish                        = var.publish
  kms_key_arn                    = var.kms_key_arn
  image_uri                      = var.image_uri
  package_type                   = var.package_type

  filename                       = var.image_uri != null ? null : data.archive_file.dummy.output_path

  dynamic "image_config" {
    for_each = length(var.image_config_entry_point) > 0 || length(var.image_config_command) > 0 || var.image_config_working_directory != null ? [true] : []
    content {
      entry_point       = var.image_config_entry_point
      command           = var.image_config_command
      working_directory = var.image_config_working_directory
    }
  }

  dynamic "environment" {
    for_each = length(keys(var.environment_variables)) == 0 ? [] : [true]
    content {
      variables = var.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_subnet_ids != null && var.vpc_security_group_ids != null ? [true] : []
    content {
      security_group_ids = var.vpc_security_group_ids
      subnet_ids         = var.vpc_subnet_ids
    }
  }

  lifecycle {
    ignore_changes = [
      filename,
      image_uri,
      source_code_hash,
      last_modified,
      qualified_arn,
      version,
      publish,
      #environment,
    ]
  }
  
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.function_name}-${local.suffix}" })
  )

}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.prefix}-${var.function_name}-${local.suffix}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.cloudwatch_logs_kms_key_id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.function_name}-${local.suffix}" })
  )
  
}

resource "aws_lambda_alias" "lambda_alias" {
  name             = local.suffix
  description      = "${local.suffix} alias"
  function_name    = aws_lambda_function.lambda.arn
  function_version = aws_lambda_function.lambda.version
}