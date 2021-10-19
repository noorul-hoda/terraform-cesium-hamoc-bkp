data "aws_iam_policy_document" "elasticsearch-log-publishing-policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]
    resources = ["arn:aws:logs:*"]
    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_group" "es-loggroup" {
  count             = var.enable_logs ? 1 : 0
  name              = "${local.prefix}-${var.name}-${local.suffix}"
  retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_log_resource_policy" "es-loggroup-policy" {
  policy_name     = "${local.prefix}-${var.name}-es-loggroup-policy-${local.suffix}"
  count           = var.enable_logs ? 1 : 0
  policy_document = data.aws_iam_policy_document.elasticsearch-log-publishing-policy.json
}

resource "aws_iam_service_linked_role" "es" {
  count            = var.create-service-link-role ? 1 : 0
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain" "elasticsearch_domain" {
  domain_name           = "${local.prefix}-${var.name}-${local.suffix}"
  elasticsearch_version = var.elasticsearch_version

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  cluster_config {
    instance_count = var.instance_count
    instance_type  = var.instance_type
  }

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  domain_endpoint_options {
    enforce_https       = var.enforce_https
    tls_security_policy = var.tls_security_policy
  }

  encrypt_at_rest {
    enabled    = var.enable_encrypt
    kms_key_id = var.kms_key_id
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
    "override_main_response_version"         = "false"
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${local.prefix}-${var.name}-${local.suffix}/*"
        }
    ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = 0
  }

  log_publishing_options {
    enabled                  = var.log_publishing_index_enabled
    log_type                 = "INDEX_SLOW_LOGS"
    cloudwatch_log_group_arn = format("%s:*", join("", aws_cloudwatch_log_group.es-loggroup.*.arn))
  }

  log_publishing_options {
    enabled                  = var.log_publishing_search_enabled
    log_type                 = "SEARCH_SLOW_LOGS"
    cloudwatch_log_group_arn = format("%s:*", join("", aws_cloudwatch_log_group.es-loggroup.*.arn))
  }

  log_publishing_options {
    enabled                  = var.log_publishing_application_enabled
    log_type                 = "ES_APPLICATION_LOGS"
    cloudwatch_log_group_arn = format("%s:*", join("", aws_cloudwatch_log_group.es-loggroup.*.arn))
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.name}-${local.suffix}" }
    )
  )

}
