output "codestar_bitbucket_arn" {
  value = aws_codestarconnections_connection.bitbucket.arn
}

output "approval_sns_arn" {
  value = aws_sns_topic.approval_sns.arn 
}

output "ecs_codebuild_loggroup" {
  value = aws_cloudwatch_log_group.ecs_codebuild.name
}

output "lambda_codebuild_loggroup" {
  value = aws_cloudwatch_log_group.lambda_codebuild.name
}

output "frontend_codebuild_loggroup" {
  value = aws_cloudwatch_log_group.frontend_codebuild.name
}

output "ecs_codebuild_loggroup_arn" {
  value = aws_cloudwatch_log_group.ecs_codebuild.arn
}

output "lambda_codebuild_loggroup_arn" {
  value = aws_cloudwatch_log_group.lambda_codebuild.arn
}

output "frontend_codebuild_loggroup_arn" {
  value = aws_cloudwatch_log_group.frontend_codebuild.arn
}