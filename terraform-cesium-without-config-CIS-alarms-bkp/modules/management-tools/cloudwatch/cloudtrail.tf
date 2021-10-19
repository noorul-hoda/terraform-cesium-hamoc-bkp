//Cloudtrail trails
//Trails s3 bucket
//Access logging S3 bucket


resource "aws_cloudtrail" "trails" {

  depends_on = [
    aws_s3_bucket_policy.cloudtrails
  ]

  name           = "${local.prefix}-${local.suffix}-trails"
  s3_bucket_name = aws_s3_bucket.cloudtrails.id
  s3_key_prefix  = "${local.prefix}-${local.suffix}"
  kms_key_id     = aws_kms_key.cloudtrail.arn


  include_global_service_events = var.include_global_service_events
  enable_log_file_validation    = var.enable_log_file_validation
  is_multi_region_trail         = var.is_multi_region_trail
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cw_events_role.arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail_loggroup.arn}:*"
}

resource "aws_cloudwatch_log_group" "cloudtrail_loggroup" {
  name              = "${local.prefix}-cloudtrail_loggroup-${local.suffix}"
  kms_key_id        = aws_kms_key.cloudtrail.arn
  retention_in_days = 60
}

resource "aws_s3_bucket" "cloudtrails" {
  bucket        = "${local.prefix}-cloudtrails-${local.suffix}"
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

  logging {
    target_bucket = aws_s3_bucket.cloudtrail-s3access-log.id
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-cloudtrails-${local.suffix}" })
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

##Access logging bucket

resource "aws_s3_bucket_public_access_block" "block-public-access-cloudtrails" {
  bucket                  = aws_s3_bucket.cloudtrails.id
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  depends_on = [
    aws_s3_bucket_policy.cloudtrails
  ]
}

resource "aws_s3_bucket" "cloudtrail-s3access-log" {
  bucket = "${local.prefix}-cloudtrail-s3access-log-${local.suffix}"
  acl    = "log-delivery-write"

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
    tomap({ "Name" = "${local.prefix}-cloudtrail-s3access-log-${local.suffix}" })
  )
}

resource "aws_s3_bucket_public_access_block" "block-public-access-cloudtrail-s3access-log" {
  bucket                  = aws_s3_bucket.cloudtrail-s3access-log.bucket
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}