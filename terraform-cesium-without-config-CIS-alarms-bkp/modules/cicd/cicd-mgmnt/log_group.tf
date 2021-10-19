resource "aws_cloudwatch_log_group" "ecs_codebuild" {
  name              = "${local.prefix}-ecs-codebuild-${local.suffix}"
  retention_in_days = 60
}

resource "aws_cloudwatch_log_group" "lambda_codebuild" {
  name              = "${local.prefix}-lambda-codebuild-${local.suffix}"
  retention_in_days = 60
}

resource "aws_cloudwatch_log_group" "frontend_codebuild" {
  name              = "${local.prefix}-frontend-codebuild-${local.suffix}"
  retention_in_days = 60
}

resource "aws_cloudwatch_log_group" "ml_lambda_codebuild" {
  name              = "${local.prefix}-ml-lambda-codebuild-${local.suffix}"
  retention_in_days = 60
}