output "invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}

output "alias_invoke_arn" {
  value = aws_lambda_alias.lambda_alias.invoke_arn
}

output "function_name" {
  value = aws_lambda_function.lambda.function_name
}