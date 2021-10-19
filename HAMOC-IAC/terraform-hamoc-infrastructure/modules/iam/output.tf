output "dataingestion_lambda_role_arn" {
  value = aws_iam_role.dataingestion_lambda_role.arn
}

output "inforeq_lambda_role_arn" {
  value = aws_iam_role.inforeq_lambda_role.arn
}

output "searchengine_lambda_role_arn" {
  value = aws_iam_role.searchengine_lambda_role.arn
}

output "externalapi_lambda_role_arn" {
  value = aws_iam_role.externalapi_lambda_role.arn
}

output "accountManagement_lambda_role_arn" {
  value = aws_iam_role.accountManagement_lambda_role.arn
}

output "dataManagement_lambda_role_arn" {
  value = aws_iam_role.dataManagement_lambda_role.arn 
}

output "userProfile_lambda_role_arn" {
value = aws_iam_role.userProfile_lambda_role.arn
}

output "uploadtos3_lambda_role_arn" {
  value = aws_iam_role.uploadtos3_lambda_role.arn
}

/*
  output "externalapi_lambda_role_arn" {
  value = aws_iam_role.externalapi_lambda_role.arn 
}
*/

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