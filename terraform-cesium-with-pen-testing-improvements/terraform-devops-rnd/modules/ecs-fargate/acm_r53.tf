//ACM Certificate and validation
//R53 Record for ECS
//# Creates the wildcard certificate *.<doamin-name.com>

resource "aws_acm_certificate" "acm-ecs-website-cert" {
  domain_name               = var.website-domain-main
  subject_alternative_names = ["*.${var.website-domain-main}", "*.${var.ecs-domain-name}"]
  validation_method         = "DNS"

  tags = merge(
    local.common_tags,
    tomap({"Name" = "${local.prefix}-acm-website-cert-${local.suffix}"}
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
    for d in aws_acm_certificate.acm-ecs-website-cert.domain_validation_options : d.domain_name => {
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
  certificate_arn         = aws_acm_certificate.acm-ecs-website-cert.arn
  validation_record_fqdns = [for r in aws_route53_record.certvalidation : r.fqdn]
}

resource "aws_route53_record" "website-url" {
  name    = var.ecs-domain-name
  type    = "A"
  zone_id = data.aws_route53_zone.hosted-zone.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_alb.ecs.dns_name
    zone_id                = aws_alb.ecs.zone_id
  }
}
