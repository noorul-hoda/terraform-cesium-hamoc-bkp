//Dummy Zip archive
//ML Lambda Functions and alias

data "archive_file" "dummy" {
  type        = "zip"
  output_path = "${path.module}/templates/lambda/dummy.zip"

  source {
    content  = "hello"
    filename = "dummy.text"
  }
}

resource "aws_lambda_function" "ml_lambda_functions" {
  depends_on       = [aws_iam_role.ml_lambda_role]
  for_each         = toset(var.ml_lambda_list)
  function_name    = "${local.prefix}-${each.key}-${local.suffix}"
  filename         = data.archive_file.dummy.output_path
  package_type     = "Zip"
  runtime          = "python3.8"
  handler          = "${each.key}.handler"

  role             = aws_iam_role.ml_lambda_role.arn
  publish          = true
  timeout          = 900
  memory_size      = 1024

  vpc_config {
    subnet_ids         = flatten([var.subnets_priv_id])
    security_group_ids = [var.sg-lambda-id]
  }

  environment {
    variables = {
      DB_NAME               = "${local.prefix}_db_${local.suffix}"
      DB_USER               = var.db-username
      DB_PASSWORD           = var.db-password
      DB_HOST               = var.db-host-address
      DB_PORT               = "5432"
      ECS_APP_URL           = "https://${var.ecs-domain-name}"
      API_GW_URL            = "https://${var.api-domain-name}"
      NOTEBOOK_INSTANCE     = "${local.prefix}-ml-notebook-instance-${local.suffix}"
      SAGEMAKER_BUCKET      = "${local.prefix}-sagemaker-bucket-${local.suffix}"
      SAGEMAKER_ROUTINE_BUCKET      = "${local.prefix}-update-routine-bucket-${local.suffix}"
      aws_access_key_id     = var.lambda-apigw-access-id
      aws_secret_access_key = var.lambda-apigw-access-secret
    }
  }

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
      last_modified,
      qualified_arn,
      version,
      publish,
      environment,
    ]
  }
}

resource "aws_lambda_alias" "ml_lambda_functions_alias" {
  for_each         = toset(var.ml_lambda_list)
  name             = local.suffix
  description      = "${local.suffix} alias"
  function_name    = aws_lambda_function.ml_lambda_functions[each.key].arn
  function_version = aws_lambda_function.ml_lambda_functions[each.key].version
}

##UpdatePredictions

# resource "aws_lambda_function" "UpdatePredictions" {
#   depends_on       = [aws_iam_role.ml_UpdatePredictions_lambda_role]
#   function_name    = "${local.prefix}-UpdatePredictions-${local.suffix}"
#   filename         = data.archive_file.dummy.output_path
#   package_type     = "Zip"
#   runtime          = "python3.8"
#   handler          = "UpdatePredictions.handler"

#   role             = aws_iam_role.ml_UpdatePredictions_lambda_role.arn
#   publish          = true
#   timeout          = 900
#   memory_size      = 1024

#   vpc_config {
#     subnet_ids         = flatten([var.subnets_priv_id])
#     security_group_ids = [var.sg-lambda-id]
#   }

#   environment {
#     variables = {
#       DB_NAME               = "${local.prefix}_db_${local.suffix}"
#       DB_USER               = var.db-username
#       DB_PASSWORD           = var.db-password
#       DB_HOST               = var.db-host-address
#       DB_PORT               = "5432"
#       ECS_APP_URL           = "https://${var.ecs_alb_dns_name}"
#       API_GW_URL            = "https://${var.api-domain-name}"
#       UPDATE_ROUTINE_BUCKET = var.update-routine-bucket-id
#       aws_access_key_id     = var.lambda-apigw-access-id
#       aws_secret_access_key = var.lambda-apigw-access-secret
#     }
#   }

#   lifecycle {
#     ignore_changes = [
#       filename,
#       source_code_hash,
#       last_modified,
#       qualified_arn,
#       version,
#       publish,
#       environment,
#     ]
#   }
# }

# resource "aws_lambda_alias" "UpdatePredictions_alias" {
#   name             = local.suffix
#   description      = "${local.suffix} alias"
#   function_name    = aws_lambda_function.UpdatePredictions.arn
#   function_version = aws_lambda_function.UpdatePredictions.version
# }
