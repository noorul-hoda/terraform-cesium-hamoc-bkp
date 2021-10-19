output "web_bucket_name" {
  value = aws_s3_bucket.frontend-bucket.bucket
}

output "cf_distribution_domain_name" {
  value = aws_cloudfront_distribution.cf-distribution.domain_name
}

output "cf_distribution_hosted_zone_id" {
  value = aws_cloudfront_distribution.cf-distribution.hosted_zone_id
}

output "cf_distribution_id" {
  value = aws_cloudfront_distribution.cf-distribution.id
}
