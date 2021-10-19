output "web-bucket-name" {
  value = aws_s3_bucket.frontend-bucket.bucket
}

# output "sub-domain-name" {
#   value = aws_route53_record.website-url.name
# }

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

output "cognito-user-pool_arn" {
  value = aws_cognito_user_pool.cognito-user-pool.arn
}

output "cognito-user-pool_domain_domain" {
  value = aws_cognito_user_pool_domain.cognito-user-pool-domain.domain
}

output "cognito-user-pool_domain_cf_arn" {
  value = aws_cognito_user_pool_domain.cognito-user-pool-domain.cloudfront_distribution_arn
}

output "test_app_url" {
  value = "https://${var.website-domain-main}.auth.${var.region}.amazoncognito.com/login?response_type=taken&client_id=${aws_cognito_user_pool_client.cognito-user-pool-client.id}&redirect_uri="
}

output "cf-distribution_domain_name" {
  value = aws_cloudfront_distribution.cf-distribution.domain_name
}

output "cf-distribution_hosted_zone_id" {
  value = aws_cloudfront_distribution.cf-distribution.hosted_zone_id
}

output "cf-distribution_id" {
  value = aws_cloudfront_distribution.cf-distribution.id
}

//https://somedomain.auth.eu-west-2.amazoncognito.com/login?response_type=token&client_id=2dj5meejjfsjv8i33edu59bs48&redirect_uri=https://www.example.com