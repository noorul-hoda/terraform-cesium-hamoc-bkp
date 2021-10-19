## Config recorder and recorder status
resource "aws_config_configuration_recorder" "recorder" {
  count = var.enable_config_recorder ? 1 : 0

  name       = "${local.prefix}-${var.config_name}-${local.suffix}"
  role_arn   = var.create_iam_role ? aws_iam_role.config-role[count.index].arn : var.iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = var.include_global_resource_types
  }
}

resource "aws_config_configuration_recorder_status" "recorder_status" {
  count = var.enable_config_recorder ? 1 : 0

  name       = "${local.prefix}-${var.config_name}-${local.suffix}"
  is_enabled = true
  depends_on = [aws_config_delivery_channel.channel]
}

##Config delivery channel
resource "aws_config_delivery_channel" "channel" {
  count = var.enable_config_recorder ? 1 : 0

  name           = "${local.prefix}-${var.config_name}-channel-${local.suffix}"
  s3_bucket_name = var.config_logs_bucket
  s3_key_prefix  = var.config_logs_prefix
  sns_topic_arn  = var.config_sns_topic_arn

  depends_on = [
    aws_config_configuration_recorder.recorder,
    aws_iam_role_policy_attachment.aws-config-policy
  ]
}

##Config Rules
resource "aws_config_config_rule" "rules" {
  for_each   = var.enable_config_recorder ? var.managed_rules : {}
  depends_on = [aws_config_configuration_recorder_status.recorder_status]

  name        = each.key
  description = each.value.description

  source {
    owner             = "AWS"
    source_identifier = each.value.identifier
  }

  input_parameters = length(each.value.input_parameters) > 0 ? jsonencode(each.value.input_parameters) : null
}

##Config IAM Role/Policies

resource "aws_iam_role" "config-role" {
  count = var.enable_config_recorder && var.create_iam_role ? 1 : 0

  name               = "${local.prefix}-${var.config_name}-role-${local.suffix}"
  assume_role_policy = data.aws_iam_policy_document.aws-config-role-policy.json
}

data "aws_iam_policy_document" "aws-config-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "config_policy_attachment" {
  count = var.enable_config_recorder && var.create_iam_role ? 1 : 0

  role       = aws_iam_role.config-role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_iam_policy" "aws-config-policy" {
  count = var.enable_config_recorder && var.create_iam_role ? 1 : 0

  name   = "${local.prefix}-${var.config_name}-policy-${local.suffix}"
  policy = data.template_file.aws_config_policy[count.index].rendered
}

resource "aws_iam_role_policy_attachment" "aws-config-policy" {
  count = var.enable_config_recorder && var.create_iam_role ? 1 : 0

  role       = aws_iam_role.config-role[count.index].name
  policy_arn = aws_iam_policy.aws-config-policy[0].arn
}

data "template_file" "aws_config_policy" {
  count = var.enable_config_recorder && var.create_iam_role ? 1 : 0

  template = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "AWSConfigBucketPermissionsCheck",
        "Effect": "Allow",
        "Action": "s3:GetBucketAcl",
        "Resource": "$${bucket_arn}"
    },
    {
        "Sid": "AWSConfigBucketExistenceCheck",
        "Effect": "Allow",
        "Action": "s3:ListBucket",
        "Resource": "$${bucket_arn}"
    },
    {
        "Sid": "AWSConfigBucketDelivery",
        "Effect": "Allow",
        "Action": "s3:PutObject",
        "Resource": "$${resource}",
        "Condition": {
          "StringLike": {
            "s3:x-amz-acl": "bucket-owner-full-control"
          }
        }
    }
  ]
}
JSON

  vars = {
    bucket_arn = format("arn:aws:s3:::%s", var.config_logs_bucket)
    resource = format(
      "arn:aws:s3:::%s%s%s/AWSLogs/%s/Config/*",
      var.config_logs_bucket,
      var.config_logs_prefix == "" ? "" : "/",
      var.config_logs_prefix,
      data.aws_caller_identity.current.account_id,
    )
  }
}