output "api-gw-invoke-url" {
  value = aws_api_gateway_stage.apiLambda.invoke_url
}

output "lambda-apigw-access-id" {
  sensitive = true
  value     = aws_iam_access_key.lambda-apigw-access.id
}

output "lambda-apigw-access-secret" {
  sensitive = true
  value     = aws_iam_access_key.lambda-apigw-access.secret
}