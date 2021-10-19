# Origin access identity
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI to access ${var.website-domain-main}"
}

# cloud-front distribution
resource "aws_cloudfront_distribution" "cf-distribution" {
  aliases             = [var.website-domain-main]
  enabled             = var.cf_enabled
  default_root_object = var.default_root_object
  web_acl_id          = var.wafv2_web_acl_arn

  origin {
    domain_name = aws_s3_bucket.frontend-bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.frontend-bucket.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.frontend-bucket.bucket_regional_domain_name
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      headers      = []
      cookies {
        forward = "none"
      }
    }

    dynamic "lambda_function_association" {
      for_each = var.lambda_function_association

      content {
        event_type   = lookup(lambda_function_association.value, "event_type", null)
        lambda_arn   = lookup(lambda_function_association.value, "lambda_arn", null)
        include_body = lookup(lambda_function_association.value, "include_body", null)
      }
    }
  }
  # This is required to be specified even if it's not used.
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_website_cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cf-standard-logs.bucket_domain_name
    prefix          = "${local.prefix}-${local.suffix}"
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.cf-distribution}-${local.suffix}" }
    )
  )
}

#Cloudfront S3 Bucket for logs

resource "aws_s3_bucket" "cf-standard-logs" {
  bucket        = "${local.prefix}-${var.cf-logs-bucket}-${local.suffix}"
  force_destroy = true

  grant {
    id          = data.aws_canonical_user_id.current_user.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  grant {
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
    id          = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
  }

  lifecycle_rule {
    enabled = var.lifecycle_rule_enable
    id      = "expire_all_files_${var.expiry_days}_days"

    transition {
      days          = var.transition_days
      storage_class = var.transition_storage_class
    }

    expiration {
      days = var.expiry_days
    }
  }
  
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.cf-logs-bucket}-${local.suffix}" })
  )
}
