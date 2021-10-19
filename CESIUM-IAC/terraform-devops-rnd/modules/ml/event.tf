//CW Event Rules
//CW Event Target
//Lambda Permission
//S3 Notification

##
resource "aws_cloudwatch_event_rule" "ActivateSaveModelResult" {
  name        = "${local.prefix}-ActivateSaveModelResult-${local.suffix}"
  description = "${local.prefix}-ActivateSaveModelResult-${local.suffix}"

  event_pattern = <<EOF
{
  "source": ["aws.sagemaker"],
  "detail-type": ["SageMaker Model State Change"]
}
EOF
}

resource "aws_cloudwatch_event_target" "ActivateSaveModelResult" {
  target_id = "${local.prefix}-ActivateSaveModelResult-${local.suffix}"
  rule      = aws_cloudwatch_event_rule.ActivateSaveModelResult.name
  arn       = aws_lambda_function.ml_lambda_functions["ActivateSaveModelResult"].arn
}

resource "aws_lambda_permission" "ActivateSaveModelResult" {
  statement_id  = "${local.prefix}-ActivateSaveModelResult-${local.suffix}"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.ml_lambda_functions["ActivateSaveModelResult"].function_name
  source_arn    = aws_cloudwatch_event_rule.ActivateSaveModelResult.arn
}

##
resource "aws_cloudwatch_event_rule" "ActivateModelTraining" {
  name                = "${local.prefix}-ActivateModelTraining-${local.suffix}"
  description         = "${local.prefix}-ActivateModelTraining-${local.suffix}"
  schedule_expression = "cron(0 0 */31 * ? *)"

  lifecycle {
    ignore_changes = [schedule_expression]
  }
}

resource "aws_cloudwatch_event_target" "ActivateModelTraining" {
  target_id = "${local.prefix}-ActivateModelTraining-${local.suffix}"
  rule      = aws_cloudwatch_event_rule.ActivateModelTraining.name
  arn       = aws_lambda_function.ml_lambda_functions["ActivateDatasetDevelopment"].arn
}

resource "aws_lambda_permission" "ActivateModelTraining" {
  statement_id  = "${local.prefix}-ActivateModelTraining-${local.suffix}"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.ml_lambda_functions["ActivateDatasetDevelopment"].function_name
  source_arn    = aws_cloudwatch_event_rule.ActivateModelTraining.arn
}

##
resource "aws_lambda_permission" "sagemaker-bucket-ActivateModelTraining" {
  statement_id  = "${local.prefix}-sagemaker-bucket-ActivateModelTraining-${local.suffix}"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.ml_lambda_functions["ActivateModelTraining"].arn
  principal      = "s3.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = var.sagemaker-bucket-arn
}

resource "aws_s3_bucket_notification" "sagemaker-bucket-ActivateModelTraining" {
  depends_on = [aws_lambda_permission.sagemaker-bucket-ActivateModelTraining]
  bucket     = var.sagemaker-bucket-id

  lambda_function {
    lambda_function_arn = aws_lambda_function.ml_lambda_functions["ActivateModelTraining"].arn
    id                  = "${local.prefix}-sagemaker-bucket-ActivateModelTraining-${local.suffix}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "data/mace"
    filter_suffix       = ".csv"
  }
}

##
resource "aws_cloudwatch_event_rule" "ActivatePredictionUpdateRoutine" {
  name                = "${local.prefix}-ActivatePredictionUpdateRoutine-${local.suffix}"
  description         = "${local.prefix}-ActivatePredictionUpdateRoutine-${local.suffix}"
  schedule_expression = "cron(0 0 */2 * ? *)"

  lifecycle {
    ignore_changes = [schedule_expression]
  }
}

resource "aws_cloudwatch_event_target" "ActivatePredictionUpdateRoutine" {
  target_id = "${local.prefix}-ActivatePredictionUpdateRoutine-${local.suffix}"
  rule      = aws_cloudwatch_event_rule.ActivatePredictionUpdateRoutine.name
  arn       = aws_lambda_function.ml_lambda_functions["ActivateUpdatePredictions"].arn
}

resource "aws_lambda_permission" "ActivatePredictionUpdateRoutine" {
  statement_id  = "${local.prefix}-ActivatePredictionUpdateRoutine-${local.suffix}"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.ml_lambda_functions["ActivateUpdatePredictions"].function_name
  source_arn    = aws_cloudwatch_event_rule.ActivatePredictionUpdateRoutine.arn
}
##