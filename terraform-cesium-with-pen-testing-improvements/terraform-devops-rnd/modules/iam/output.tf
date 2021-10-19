output "ecs_pipeline_role_arn" {
  value = aws_iam_role.ecs-pipeline-role.arn
}

output "ecs_codebuild_role_arn" {
  value = aws_iam_role.ecs-codebuild-role.arn
}

output "frontend_backend_pipeline_role_arn" {
  value = aws_iam_role.frontend_backend-pipeline-role.arn
}

output "lambda_codebuild_role_arn" {
  value = aws_iam_role.lambda-codebuild-role.arn
}

output "frontend_codebuild_role_arn" {
  value = aws_iam_role.frontend-codebuild-role.arn
}

output "ml_lambda_pipeline_role_arn" {
  value = aws_iam_role.ml-lambda-pipeline-role.arn
}

output "ml_lambda_codebuild_role_arn" {
  value = aws_iam_role.ml-lambda-codebuild-role.arn
}