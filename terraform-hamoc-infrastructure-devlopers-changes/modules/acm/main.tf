##ACM Certificate and validation
##Creates the wildcard certificate *.<domain-name.com>

resource "aws_acm_certificate" "acm-website-cert" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    tomap({"Name" = "${local.prefix}-${var.name}-${local.suffix}"}
    )
  )
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
  certificate_arn         = aws_acm_certificate.acm-website-cert.arn
  validation_record_fqdns = [for r in aws_route53_record.certvalidation : r.fqdn]
}