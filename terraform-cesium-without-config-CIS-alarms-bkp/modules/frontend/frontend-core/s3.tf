## s3 bucket for the frontend webhosting
# IAM policy
# SSM parameters

resource "aws_s3_bucket" "frontend-bucket" {
  bucket        = "${local.prefix}-web-bucket-${local.suffix}"
  acl           = "private"
  force_destroy = false
  lifecycle {
    prevent_destroy = true
  }
  versioning {
    enabled = true
  }

  tags = merge(
    local.common_tags,
    tomap({"Name" = "${local.prefix}-web-bucket-${local.suffix}" }
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

# resource "aws_ssm_parameter" "web-bucket-arn" {
#   name  = "/${local.prefix}/${local.suffix}/web-bucket-arn"
#   type  = "String"
#   value = aws_s3_bucket.frontend-bucket.arn
# }