## WAFv2 for cloudfront
# Firewall for the Ip whitelisting/blacklisting
# SSM parameters

resource "aws_wafv2_rule_group" "rule-group" {
  provider = aws.acm-virginia
  name     = "${local.prefix}-rule-group"
  scope    = "CLOUDFRONT"
  capacity = 20
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.prefix}-rule-group-visibility"
    sampled_requests_enabled   = true
  }
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-rules-group-${local.suffix}" }
    )
  )
}

# wafv2 web ACL
resource "aws_wafv2_web_acl" "wafv2-web-acl" {
  provider    = aws.acm-virginia
  name        = "${local.prefix}-wafv2-web-acl-${local.suffix}"
  scope       = "CLOUDFRONT"
  description = "wafv2 web acl for CLOUDFRONT with default all actions blocked"
  default_action {
    block {}
  }
  # whitelist rule
  rule {
    name     = "security-firewall-whitelist-rule-ipv4"
    priority = 3

    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.whitelist-ipset-ipv4.arn
      }
    }
    //    statement {
    //      rule_group_reference_statement {
    //        arn = aws_wafv2_rule_group.rule-group.arn
    //      }
    //    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.prefix}-visibility-whitelist-rule-ipv4"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "security-firewall-whitelist-rule-ipv6"
    priority = 4

    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.whitelist-ipset-ipv6.arn
      }
    }
    //    statement {
    //      rule_group_reference_statement {
    //        arn = aws_wafv2_rule_group.rule-group.arn
    //      }
    //    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.prefix}-visibility-whitelist-rule-ipv6"
      sampled_requests_enabled   = true
    }
  }


  # blacklist rule
  rule {
    name     = "security-firewall-blacklist-rule-ipv4"
    priority = 1

    action {
      block {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blacklist-ipset-ipv4.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.prefix}-visibility-blacklist-rule-ipv4"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "security-firewall-blacklist-rule-ipv6"
    priority = 2

    action {
      block {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blacklist-ipset-ipv6.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.prefix}-visibility-blacklist-rule-ipv6"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.prefix}-visibility-wafv2-web-acl"
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




# wafv2 whitelist ipset Ips
resource "aws_wafv2_ip_set" "whitelist-ipset-ipv4" {
  provider           = aws.acm-virginia
  name               = "${local.prefix}-whitelist-ipset-ipv4-${local.suffix}"
  description        = "${local.prefix}  white listed ipv4 addresses"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  #addresses          = "${formatlist("%s/32", concat(var.cf_whitelist_ipv4-list))}"
  addresses          =  flatten(["${var.cf_whitelist_ipv4-list}"])

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-whitelist-ipset-ipv4" })
  )
}

resource "aws_wafv2_ip_set" "whitelist-ipset-ipv6" {
  provider           = aws.acm-virginia
  name               = "${local.prefix}-whitelist-ipset-ipv6-${local.suffix}"
  description        = "${local.prefix}  white listed ipv6 addresses"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV6"
  #addresses          = "${formatlist("%s/128", concat(var.cf_whitelist_ipv6-list))}"
  addresses          =  flatten(["${var.cf_whitelist_ipv6-list}"])

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-whitelist-ipset-ipv6" })
  )
}


# wafv2 blacklist ipset Ips
resource "aws_wafv2_ip_set" "blacklist-ipset-ipv4" {
  provider           = aws.acm-virginia
  name               = "${local.prefix}-blacklist-ipset-ipv4-${local.suffix}"
  description        = "${local.prefix}  black listed ipv4 addresses"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  #addresses          = "${formatlist("%s/32", concat(var.cf_blacklist_ipv4-list))}"
  addresses          =  flatten(["${var.cf_blacklist_ipv4-list}"])

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-blacklist-ipset-ipv4" })
  )
}

resource "aws_wafv2_ip_set" "blacklist-ipset-ipv6" {
  provider           = aws.acm-virginia
  name               = "${local.prefix}-blacklist-ipset-ipv6-${local.suffix}"
  description        = "${local.prefix}  black listed ipv6 addresses"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV6"
  #addresses          = "${formatlist("%s/128", concat(var.cf_blacklist_ipv6-list))}"
  addresses          =  flatten(["${var.cf_blacklist_ipv6-list}"])

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-blacklist-ipset-ipv6" })
  )
}

# SSM Parameters
# resource "aws_ssm_parameter" "wafv2-web-acl-id" {
#   provider = aws
#   name     = "/${local.prefix}/wafv2-web-acl-id"
#   type     = "String"
#   value    = aws_wafv2_web_acl.wafv2-web-acl.id
# }

# resource "aws_ssm_parameter" "wafv2-web-acl-arn" {
#   provider = aws
#   name     = "/${local.prefix}/wafv2-web-acl-arn"
#   type     = "String"
#   value    = aws_wafv2_web_acl.wafv2-web-acl.arn
# }

