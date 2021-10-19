output "ml-sagemaker-role-arn" {
  value = aws_iam_role.sagemaker-role.arn
}

output "ml_lambda_role-arn" {
  #value = aws_lambda_function.ml_lambda_functions.*.arn
  value = aws_iam_role.ml_lambda_role.arn
}