output "user_pool_id" {
  value = aws_cognito_user_pool.cognito-user-pool.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.cognito-user-pool-client.id
}

output "identity_pool_id" {
  value = aws_cognito_identity_pool.cognito-identity-pool.id
}

output "callback_urls" {
  value = aws_cognito_user_pool_client.cognito-user-pool-client.callback_urls
}

output "cognito_user_pool_arn" {
  value = aws_cognito_user_pool.cognito-user-pool.arn
}

output "cognito_user_pool_domain_domain" {
  value = aws_cognito_user_pool_domain.cognito-user-pool-domain.domain
}

output "cognito_user_pool_domain_cf_arn" {
  value = aws_cognito_user_pool_domain.cognito-user-pool-domain.cloudfront_distribution_arn
}