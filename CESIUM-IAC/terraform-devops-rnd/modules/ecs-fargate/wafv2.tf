## WAFv2 for ECS ALB
# Firewall for the Ip blacklisting

resource "aws_wafv2_rule_group" "alb-rule-group" {
  name     = "${local.prefix}-alb-rules-group-${local.suffix}"
  scope    = "REGIONAL"
  capacity = 20
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.prefix}-alb-rule-group-visibility"
    sampled_requests_enabled   = true
  }
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-alb-rules-group-${local.suffix}" }
    )
  )
}

# wafv2 web ACL
resource "aws_wafv2_web_acl" "alb-wafv2-web-acl" {
  name        = "${local.prefix}-alb-wafv2-web-acl-${local.suffix}"
  scope       = "REGIONAL"
  description = "wafv2 web acl for ALB with default all actions allow"

  default_action {
    allow {}
  }

  # blacklist rule
  rule {
    name     = "alb-security-firewall-blacklist-rule-ipv4"
    priority = 1

    action {
      block {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.alb-blacklist-ipset-ipv4.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.prefix}-alb-visibility-blacklist-rule-ipv4-${local.suffix}"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "alb-security-firewall-blacklist-rule-ipv6"
    priority = 2

    action {
      block {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.alb-blacklist-ipset-ipv6.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.prefix}-alb-visibility-blacklist-rule-ipv6-${local.suffix}"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.prefix}-alb-visibility-wafv2-web-acl-${local.suffix}"
    sampled_requests_enabled   = true
  }

  ##AWS Managed WAF rules

  dynamic "rule" {
    for_each = var.managed_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        dynamic "none" {
          for_each = rule.value.override_action == "none" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.override_action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = "AWS"

          dynamic "excluded_rule" {
            for_each = rule.value.excluded_rules
            content {
              name = excluded_rule.value
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-wafv2-rules-${local.suffix}" })
  )
}

# wafv2 blacklist ipset Ips
resource "aws_wafv2_ip_set" "alb-blacklist-ipset-ipv4" {
  name               = "${local.prefix}-alb-blacklist-ipset-ipv4-${local.suffix}"
  description        = "${local.prefix}  ALB black listed ipv4 addresses"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  #addresses          = "${formatlist("%s/32", concat(var.alb_blacklist_ipv4-list))}"
  addresses          = flatten(["${var.alb_blacklist_ipv4-list}"])

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-blacklist-ipset-ipv4-${local.suffix}" })
  )
}

resource "aws_wafv2_ip_set" "alb-blacklist-ipset-ipv6" {
  name               = "${local.prefix}-alb-blacklist-ipset-ipv6-${local.suffix}"
  description        = "${local.prefix}  ALB black listed ipv6 addresses"
  scope              = "REGIONAL"
  ip_address_version = "IPV6"
  #addresses          = "${formatlist("%s/128", concat(var.alb_blacklist_ipv6-list))}"
  addresses          = flatten(["${var.alb_blacklist_ipv6-list}"])

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-alb-blacklist-ipset-ipv6-${local.suffix}" })
  )
}

#WAFV2 ALB Association

resource "aws_wafv2_web_acl_association" "alb-association" {
  resource_arn = aws_alb.ecs.arn
  web_acl_arn  = aws_wafv2_web_acl.alb-wafv2-web-acl.arn
}

