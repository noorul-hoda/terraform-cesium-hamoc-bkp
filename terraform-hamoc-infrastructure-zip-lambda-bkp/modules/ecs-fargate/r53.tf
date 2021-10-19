//R53 Record for ECS

data "aws_route53_zone" "hosted-zone" {
  name         = var.website-domain-main
  private_zone = false
}

resource "aws_route53_record" "website-url" {
  name            = var.ecs-domain-name
  type            = "A"
  zone_id         = data.aws_route53_zone.hosted-zone.zone_id
  allow_overwrite = true

  alias {
    evaluate_target_health = true
    name                   = aws_alb.ecs.dns_name
    zone_id                = aws_alb.ecs.zone_id
  }
}
