##ECS ALB

resource "aws_alb" "ecs" {
  depends_on = [
    aws_s3_bucket_policy.alb-logs-s3
  ]
  idle_timeout               = var.idle_timeout
  internal                   = var.internal
  name                       = "${local.prefix}-${var.name}-alb-${local.suffix}"
  security_groups            = var.alb_security_groups
  subnets                    = var.alb_subnets
  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket  = aws_s3_bucket.alb-logs.bucket
    prefix  = "${local.prefix}-ecs-${local.suffix}"
    enabled = var.enable_access_logs
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.name}-alb-${local.suffix}" })
  )
}

##ECS ALB Target Group

resource "aws_alb_target_group" "ecs-tg" {
  name                 = "${local.prefix}-${var.name}-alb-tg-${local.suffix}"
  port                 = var.tg_port
  protocol             = var.tg_protocol
  vpc_id               = var.vpc_id
  target_type          = var.target_type
  deregistration_delay = var.deregistration_delay

  dynamic "health_check" {
  for_each = var.health_check
  content {
      enabled             = lookup(health_check.value, "enabled", null)
      interval            = lookup(health_check.value, "interval", null)
      path                = lookup(health_check.value, "path", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
      timeout             = lookup(health_check.value, "timeout", null)
      protocol            = lookup(health_check.value, "protocol", null)
      matcher             = lookup(health_check.value, "matcher", null)
  }
  }

  dynamic "stickiness" {
    for_each = var.stickiness

    content {
      enabled         = lookup(stickiness.value, "enabled", null)
      cookie_duration = lookup(stickiness.value, "cookie_duration", null)
      type            = lookup(stickiness.value, "type", null)
    }
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.name}-alb-tg-${local.suffix}" })
  )
}

##ECS ALB Listener/Listener rules

resource "aws_alb_listener" "ecs_http_80" {
  load_balancer_arn = aws_alb.ecs.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "ecs_https_443" {

  load_balancer_arn = aws_alb.ecs.id
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.ecs-tg.id
    type             = "forward"
  }
}

##ALB Logs S3 Bucket and policies

resource "aws_s3_bucket" "alb-logs" {
  bucket        = "${local.prefix}-${var.alb_logs_bucket}-${local.suffix}"
  force_destroy = true

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
    tomap({ "Name" = "${local.prefix}-${var.alb_logs_bucket}-${local.suffix}" })
  )
}

resource "aws_s3_bucket_policy" "alb-logs-s3" {
  bucket = aws_s3_bucket.alb-logs.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.main.arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.alb-logs.arn}/${local.prefix}-ecs-${local.suffix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.alb-logs.arn}/${local.prefix}-ecs-${local.suffix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.alb-logs.arn}"
    }
  ]
}
POLICY
}
