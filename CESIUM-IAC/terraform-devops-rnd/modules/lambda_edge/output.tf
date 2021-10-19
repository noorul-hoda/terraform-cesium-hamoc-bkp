output "lambda-edge_qualified_arn" {
  value = aws_lambda_function.edge_lambda[0].qualified_arn
}

