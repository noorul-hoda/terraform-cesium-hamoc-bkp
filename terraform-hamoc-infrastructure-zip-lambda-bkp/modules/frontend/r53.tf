data "aws_route53_zone" "hosted-zone" {
  name         = var.website-domain-main
  private_zone = false
}

# R53 Record Set

resource "aws_route53_record" "website-url" {
  name            = var.website-domain-main
  type            = "A"
  zone_id         = data.aws_route53_zone.hosted-zone.zone_id
  allow_overwrite = true

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.cf-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cf-distribution.hosted_zone_id
  }
}
