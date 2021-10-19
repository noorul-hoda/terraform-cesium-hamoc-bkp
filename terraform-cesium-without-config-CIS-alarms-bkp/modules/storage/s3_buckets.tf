## s3 buckets
// sagemaker bucket
// lambda-packages bucket

##S3 Bucket Buld Loading
resource "aws_s3_bucket" "bulk-load" {
  bucket = "${local.prefix}-bulk-load-${local.suffix}"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  force_destroy = false

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = merge(
  local.common_tags,
  tomap({ "Name" = "${local.prefix}-bulk-load-${local.suffix}" })
  )
}

## cesium SageMaker bucket:
resource "aws_s3_bucket" "sagemaker-bucket" {
  bucket = "${local.prefix}-sagemaker-bucket-${local.suffix}"
  acl    = "public-read"

  lifecycle {
    prevent_destroy = true
  }

  force_destroy = false

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = merge(
  local.common_tags,
  tomap({ "Name" = "${local.prefix}-sagemaker-bucket-${local.suffix}" })
  )
}

resource "aws_s3_bucket_policy" "policy-sagemaker-bucket" {
  bucket     = aws_s3_bucket.sagemaker-bucket.id
  depends_on = [aws_s3_bucket.sagemaker-bucket]
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "SagemakerBucketPolicy"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.sagemaker-bucket.arn,
          "${aws_s3_bucket.sagemaker-bucket.arn}/*",
        ]
      }
    ]
  }
  )

}
resource "aws_s3_bucket_public_access_block" "block-public-access-sagemaker" {
  bucket                  = aws_s3_bucket.sagemaker-bucket.bucket
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  depends_on              = [aws_s3_bucket.sagemaker-bucket, aws_s3_bucket_policy.policy-sagemaker-bucket]

}


## Lambda function bucket:
resource "aws_s3_bucket" "lambda-packages" {
  bucket = "${local.prefix}-lambda-packages-${local.suffix}"
  acl    = "private"

  lifecycle {
    prevent_destroy = false
  }

  force_destroy = true

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = merge(
  local.common_tags,
  tomap({ "Name" = "${local.prefix}-lambda-packages-${local.suffix}" })
  )
}

resource "aws_s3_bucket_public_access_block" "block-public-access-lambda" {
  bucket                  = aws_s3_bucket.lambda-packages.bucket
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}

##Update Routine Bucket for ML

resource "aws_s3_bucket" "update-routine-bucket" {
  bucket = "${local.prefix}-update-routine-bucket-${local.suffix}"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  force_destroy = false

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = merge(
  local.common_tags,
  tomap({ "Name" = "${local.prefix}-update-routine-bucket-${local.suffix}" })
  )
}

resource "aws_s3_bucket_public_access_block" "block-public-access-update-routine-bucket" {
  bucket                  = aws_s3_bucket.update-routine-bucket.bucket
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}


##Adhoc bucket for MACE

resource "aws_s3_bucket" "mace-bucket" {
  bucket = "${local.prefix}-mace-bucket-${local.suffix}"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  force_destroy = false

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = merge(
  local.common_tags,
  tomap({ "Name" = "${local.prefix}-mace-bucket-${local.suffix}" })
  )
}

resource "aws_s3_bucket_public_access_block" "block-public-access-update-mace-bucket" {
  bucket                  = aws_s3_bucket.mace-bucket.bucket
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}