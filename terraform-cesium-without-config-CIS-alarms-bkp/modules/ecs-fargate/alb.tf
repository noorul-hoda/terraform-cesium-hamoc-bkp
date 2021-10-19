//ECS ALB
//ECS ALB Target Group
//ECS ALB Listener/Listener rules
//ALB Logs S3 Bucket and policies


resource "aws_alb" "ecs" {
  depends_on = [
    aws_s3_bucket_policy.alb-logs-s3
  ]
  idle_timeout    = 60
  internal        = false
  name            = "${local.prefix}-ecs-alb-${local.suffix}"
  security_groups = [var.sg-alb-id]
  #subnets         = split(",", var.subnets_pub_id)
  subnets                    = flatten(["${var.subnets_pub_id}"])
  enable_deletion_protection = true
  drop_invalid_header_fields = true

  access_logs {
    bucket  = aws_s3_bucket.alb-logs.bucket
    prefix = "${local.prefix}-ecs-${local.suffix}"
    enabled = local.suffix == "dev" ? false : true
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ecs-alb-${local.suffix}" })
  )
}

resource "aws_alb_target_group" "ecs-tg" {
  name                 = "${local.prefix}-ecs-alb-tg-${local.suffix}"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc-id
  target_type          = "ip"
  deregistration_delay = "300"


  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ecs-alb-tg-${local.suffix}" })
  )
}

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
  certificate_arn   = aws_acm_certificate.acm-ecs-website-cert.arn

  default_action {
    target_group_arn = aws_alb_target_group.ecs-tg.id
    type             = "forward"
  }
}


resource "aws_s3_bucket" "alb-logs" {
  bucket        = "${local.prefix}-alb-logs-${local.suffix}"
  force_destroy = true

  lifecycle_rule {
    enabled = true
    id      = "expire_all_files_60_days"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 60
    }
  }
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-alb-logs-${local.suffix}" })
  )
}

resource "aws_s3_bucket_policy" "alb-logs-s3" {
  bucket     = aws_s3_bucket.alb-logs.id
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
