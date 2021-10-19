##Cloudtrail Trails

resource "aws_cloudtrail" "trails" {
  depends_on = [
    aws_s3_bucket_policy.cloudtrails
  ]
  name           = "${local.prefix}-${local.suffix}-${var.trail_name}"
  s3_bucket_name = aws_s3_bucket.cloudtrails.id
  s3_key_prefix  = "${local.prefix}-${local.suffix}"
  kms_key_id     = aws_kms_key.cloudtrail.arn

  include_global_service_events = var.include_global_service_events
  enable_log_file_validation    = var.enable_log_file_validation
  is_multi_region_trail         = var.is_multi_region_trail
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cw_events_role.arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail_loggroup.arn}:*"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${local.suffix}-${var.trail_name}" })
  )
}

##Cloudtrail Log group

resource "aws_cloudwatch_log_group" "cloudtrail_loggroup" {
  name              = "${local.prefix}-${var.cloudwatch_log_group_name}-${local.suffix}"
  kms_key_id        = aws_kms_key.cloudtrail.arn
  retention_in_days = var.log_retention_days
}

##Cloudtrail S3 bucket and Bucket Policy

resource "aws_s3_bucket" "cloudtrails" {
  bucket        = "${local.prefix}-${var.cloudtrail_bucketname}-${local.suffix}"
  force_destroy = true
  
  dynamic "logging" {
    for_each = length(keys(var.logging)) == 0 ? [] : [var.logging]

    content {
      target_bucket = logging.value.target_bucket
      target_prefix = lookup(logging.value, "target_prefix", null)
    }
  }

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
    tomap({ "Name" = "${local.prefix}-${var.cloudtrail_bucketname}-${local.suffix}" })
  )
}

resource "aws_s3_bucket_policy" "cloudtrails" {
  bucket = aws_s3_bucket.cloudtrails.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.cloudtrails.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.cloudtrails.arn}/${local.prefix}-${local.suffix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "block-public-access" {
  bucket                  = aws_s3_bucket.cloudtrails.id
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true

  depends_on = [
    aws_s3_bucket_policy.cloudtrails
  ]
}