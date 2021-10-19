##S3 bucket for the frontend webhosting

resource "aws_s3_bucket" "frontend-bucket" {
  bucket        = "${local.prefix}-${var.web-bucket}-${local.suffix}"
  acl           = "private"
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = var.lifecycle_rule_enable
    id      = "expire_all_noncurrent_version_files_${var.expiry_days}_days"

    noncurrent_version_expiration  {
        days = var.expiry_days
    }
  }

  tags = merge(
    local.common_tags,
    tomap({"Name" = "${local.prefix}-${var.web-bucket}-${local.suffix}" }
    )
  )
}

# IAM policy for OAI to s3
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      aws_s3_bucket.frontend-bucket.arn,
      "${aws_s3_bucket.frontend-bucket.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block-public-access-frontend-bucket" {
  bucket                  = aws_s3_bucket.frontend-bucket.bucket
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  depends_on              = [data.aws_iam_policy_document.s3_policy, aws_s3_bucket_policy.frontend-bucket-policy]
}

resource "aws_s3_bucket_policy" "frontend-bucket-policy" {
  bucket = aws_s3_bucket.frontend-bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}