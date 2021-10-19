//Lambda functions

data "aws_ecr_repository" "hello-world" {
  name = "sample-hello-world"
}

resource "aws_lambda_function" "lambda_functions" {
  depends_on    = [aws_iam_role.lambda_role]
  for_each      = toset(var.lambda_list)
  function_name = "${local.prefix}-${each.key}-${local.suffix}"
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_repository.hello-world.repository_url}:latest"
  role          = aws_iam_role.lambda_role.arn
  publish       = true
  timeout       = 900
  memory_size   = 1024

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
      aws_access_key_id     = aws_iam_access_key.lambda-apigw-access.id
      aws_secret_access_key = aws_iam_access_key.lambda-apigw-access.secret
    }
  }

  lifecycle {
    ignore_changes = [
      image_uri,
      last_modified,
      qualified_arn,
      version,
      publish,
      environment,
    ]
  }
}

resource "aws_lambda_alias" "lambda_functions_alias" {
  for_each         = toset(var.lambda_list)
  name             = local.suffix
  description      = "${local.suffix} alias"
  function_name    = aws_lambda_function.lambda_functions[each.key].arn
  function_version = aws_lambda_function.lambda_functions[each.key].version
}

##Old code
//Create lambda layer
//resource "aws_lambda_layer_version" "lambda_layer_nichepy" {
//  layer_name = "nichepy-bundle-layer"
//  filename = "${path.module}/lambda_module/layer/nichepy-bundle-layer.zip"
//  compatible_runtimes = ["python3.7","python3.8"]
//
//}

## Lambda functions and corresponding layers:
//locals {
//  lambda_function_niche = {
//    associatesNetworkLoad = nichepyBundleLayer
//    associatesNetworkGrow = nichepyBundleLayer
//    personProfile = nichepyBundleLayer
//    profileSearch = nichepyBundleLayer
////    plotStats = compactpyBundleLayer
//    queryStatsCache = nichepyBundleLayer
//    personTimeline = nichepyBundleLayer
//    queryCompareCache = nichepyBundleLayer
////    algoPredict = [nichepyBundleLayer,sklearnLayer]
//    etl_GetNicheID = nichepyBundleLayer
//    etl_GetData = nichepyBundleLayer
////    etl_GetMaceData = [nichepyBundleLayer, sklearnLayer]
//    etl_SaveMaceData = nichepyBundleLayer
//    etl_dynamoData = nichepyBundleLayer
//  }
//}
# data "aws_lambda_layer_version" "lambda_layer_nichepy" {
#   layer_name = "nichepy-bundle-layer"
# }

# data "aws_lambda_layer_version" "lambda_layer_sklearn" {
#   layer_name = "sklearn-layer"
# }
# data "aws_lambda_layer_version" "lambda_layer_compactpy" {
#   layer_name = "compactpy-bundle-layer"
# }
# data "archive_file" "ziplambdafileniche" {

#   type        = "zip"
#   for_each = toset(var.niche_lambdas)
#   source_file = "${path.module}/lambda_module/lambda/${each.key}.py"

#   output_path = "${path.module}/lambda_module/lambda/${each.key}.zip"

# }
# data "archive_file" "ziplambdafilecompactpy" {

#   type        = "zip"
#   for_each = toset( var.compactpy_lambdas )
#   source_file = "${path.module}/lambda_module/lambda/${each.key}.py"

#   output_path = "${path.module}/lambda_module/lambda/${each.key}.zip"

# }

# data "archive_file" "ziplambdafilesklearnniche" {

#   type        = "zip"
#   for_each = toset( var.niche_sklearn_lambdas )
#   source_file = "${path.module}/lambda_module/lambda/${each.key}.py"

#   output_path = "${path.module}/lambda_module/lambda/${each.key}.zip"

# }

# resource "aws_lambda_function" "lambda_functions_niche" {
#   for_each = toset( var.niche_lambdas)
#   function_name = "${local.prefix}-${each.key}-${local.suffix}"
#   handler       = "${each.key}.handler"
#   #filename = "${path.module}/lambda_module/lambda/${each.key}.zip"
#   image_uri     = "public.ecr.aws/lambda/python:3.7"
#   role          = aws_iam_role.lambda_role.arn
#   runtime       = "python3.7"
#   #layers = [data.aws_lambda_layer_version.lambda_layer_nichepy.arn]
#   #source_code_hash = "${data.archive_file.ziplambdafileniche[each.key].output_base64sha256}"
#   #depends_on = [data.archive_file.ziplambdafileniche]
# }
# resource "aws_lambda_function" "lambda_functions_compactpy" {
#   for_each = toset( var.compactpy_lambdas)
#   function_name = "${local.prefix}-${each.key}-${local.suffix}"
#   handler       = "${each.key}.handler"
#   #filename = "${path.module}/lambda_module/lambda/${each.key}.zip"
#   image_uri     = "public.ecr.aws/lambda/python:3.7"
#   role          = aws_iam_role.lambda_role.arn
#   runtime       = "python3.7"
#   #layers = [data.aws_lambda_layer_version.lambda_layer_compactpy.arn]
#   #source_code_hash = "${data.archive_file.ziplambdafilecompactpy[each.key].output_base64sha256}"
#   #depends_on = [data.archive_file.ziplambdafilecompactpy]
# }

# resource "aws_lambda_function" "lambda_functions_sklearn_niche" {
#   for_each = toset( var.niche_sklearn_lambdas )
#   function_name = "${local.prefix}-${each.key}-${local.suffix}"
#   handler = "${each.key}.handler"
#   #filename = "${path.module}/lambda_module/lambda/${each.key}.zip"
#   image_uri     = "public.ecr.aws/lambda/python:3.7"
#   role = aws_iam_role.lambda_role.arn
#   runtime = "python3.7"
#   #layers = [
#   #  data.aws_lambda_layer_version.lambda_layer_sklearn.arn,
#   #  data.aws_lambda_layer_version.lambda_layer_nichepy.arn]
#   #source_code_hash = "${data.archive_file.ziplambdafilesklearnniche[each.key].output_base64sha256}"
#   #depends_on = [data.archive_file.ziplambdafilesklearnniche]
# }
