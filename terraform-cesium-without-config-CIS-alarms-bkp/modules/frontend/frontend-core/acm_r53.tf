## Amazon certificate manager
# wildcard certificate creation
# certificate validation
# SSM parameters

## ACM (AWS Certificate Manager)
//# Creates the wildcard certificate *.<doamin-name.com>

resource "aws_acm_certificate" "acm-website-cert" {
  provider                  = aws.acm-virginia
  domain_name               = var.website-domain-main
  subject_alternative_names = ["*.${var.website-domain-main}"]
  validation_method         = "DNS"

  tags = merge(
  local.common_tags,
  tomap({ "Name" = "${local.prefix}-acm-website-cert-${local.suffix}" }
  )
  )
}

data "aws_route53_zone" "hosted-zone" {
  name         = var.website-domain-main
  private_zone = false
}

resource "aws_route53_record" "certvalidation" {
  provider = aws
  for_each = {
  for d in aws_acm_certificate.acm-website-cert.domain_validation_options : d.domain_name => {
    name   = d.resource_record_name
    record = d.resource_record_value
    type   = d.resource_record_type
  }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted-zone.zone_id
}

# certificate validation
resource "aws_acm_certificate_validation" "cert-validation" {
  provider                = aws.acm-virginia
  certificate_arn         = aws_acm_certificate.acm-website-cert.arn
  validation_record_fqdns = [for r in aws_route53_record.certvalidation : r.fqdn]
}

# R53 Record Set

resource "aws_route53_record" "website-url" {
  name    = var.website-domain-main
  type    = "A"
  zone_id = data.aws_route53_zone.hosted-zone.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.cf-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cf-distribution.hosted_zone_id
  }
}

resource "aws_route53_record" "auth-cognito-record" {
  name    = aws_cognito_user_pool_domain.cognito-user-pool-domain.domain
  type    = "A"
  zone_id = data.aws_route53_zone.hosted-zone.zone_id
  allow_overwrite = true
  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.cognito-user-pool-domain.cloudfront_distribution_arn
    # This zone_id is fixed
    zone_id = "Z2FDTNDATAQYW2"
  }
}

