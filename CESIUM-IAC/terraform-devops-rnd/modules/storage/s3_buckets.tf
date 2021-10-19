## s3 buckets
// sagemaker bucket
// lambda-packages bucket

##S3 Bucket Buld Loading
resource "aws_s3_bucket" "bulk-load" {
  bucket = "${local.prefix}-bulk-load-${local.suffix}"
  acl    = "private"
  depends_on = [aws_s3_bucket.bulk-load-s3access-log, aws_s3_bucket_policy.policy-bulk-load-s3access-log-bucket]

  logging {
    target_bucket = aws_s3_bucket.bulk-load-s3access-log.id
    target_prefix = "log/"
  }

  lifecycle {
    prevent_destroy = true
  }

  force_destroy = false

  versioning {
    enabled = true
    mfa_delete = true
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

resource "aws_s3_bucket_public_access_block" "block-public-access-bulk-load" {
  bucket                  = aws_s3_bucket.bulk-load.bucket
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  depends_on              = [aws_s3_bucket.bulk-load, aws_s3_bucket_policy.policy-bulk-load-bucket]
}

resource "aws_s3_bucket_policy" "policy-bulk-load-bucket" {
  bucket = aws_s3_bucket.bulk-load.id
  depends_on = [aws_s3_bucket.bulk-load]
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "BulkLoadBucketPolicy"
    Statement = [
      {
        Sid       = "S3BucketSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.bulk-load.arn,
          "${aws_s3_bucket.bulk-load.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
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
    mfa_delete = true
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
  bucket = aws_s3_bucket.sagemaker-bucket.id
  depends_on = [
    aws_s3_bucket.sagemaker-bucket]
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "SagemakerBucketPolicy",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": {
                "AWS": [ "${var.ml_lambda_role-arn}", "${var.ml-sagemaker-role-arn}" ]
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "${aws_s3_bucket.sagemaker-bucket.arn}",
                "${aws_s3_bucket.sagemaker-bucket.arn}/*"
            ]
        },
        {
            "Sid": "AllowSSLRequestsOnly",
            "Action": "s3:*",
            "Effect": "Deny",
            "Principal": "*",
            "Resource": "${aws_s3_bucket.sagemaker-bucket.arn}",
            "Condition": {
  	          "Bool": {
                  "aws:SecureTransport": "false"
              }
            }
        }
    ]
}
EOF
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
    prevent_destroy = true
  }

  force_destroy = true

  versioning {
    enabled = true
    mfa_delete = true
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


resource "aws_s3_bucket_policy" "policy-lambda-packages-bucket" {
  bucket = aws_s3_bucket.lambda-packages.id
  depends_on = [aws_s3_bucket.lambda-packages]
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "BulkLoadBucketPolicy"
    Statement = [
      {
        Sid       = "S3BucketSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.lambda-packages.arn,
          "${aws_s3_bucket.lambda-packages.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
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
    mfa_delete = true
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

resource "aws_s3_bucket_policy" "policy-update-routine-bucket" {
  bucket = aws_s3_bucket.update-routine-bucket.id
  depends_on = [aws_s3_bucket.update-routine-bucket]
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "BulkLoadBucketPolicy"
    Statement = [
      {
        Sid       = "S3BucketSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.update-routine-bucket.arn,
          "${aws_s3_bucket.update-routine-bucket.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
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
  depends_on = [aws_s3_bucket.mace-s3access-log, aws_s3_bucket_policy.policy-mace-s3access-log-bucket]

  logging {
    target_bucket = aws_s3_bucket.mace-s3access-log.id
    target_prefix = "log/"
  }

  lifecycle {
    prevent_destroy = true
  }

  force_destroy = false

  versioning {
    enabled = true
    mfa_delete = true
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


resource "aws_s3_bucket_policy" "policy-mace-bucket" {
  bucket = aws_s3_bucket.mace-bucket.id
  depends_on = [aws_s3_bucket.mace-bucket]
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "BulkLoadBucketPolicy"
    Statement = [
      {
        Sid       = "S3BucketSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.mace-bucket.arn,
          "${aws_s3_bucket.mace-bucket.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "block-public-access-update-mace-bucket" {
  bucket                  = aws_s3_bucket.mace-bucket.bucket
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}




#Bulk-Load-Access-bucket
resource "aws_s3_bucket" "bulk-load-s3access-log" {
  bucket = "${local.prefix}-bulk-load-s3access-log-${local.suffix}"
  acl    = "log-delivery-write"

  lifecycle {
    prevent_destroy = true
  }

  force_destroy = false

  versioning {
    enabled = true
    #mfa_delete = true
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
  tomap({ "Name" = "${local.prefix}-bulk-load-s3access-log-${local.suffix}" })
  )
}

resource "aws_s3_bucket_public_access_block" "block-public-access-bulk-load-s3access-log" {
  bucket                  = aws_s3_bucket.bulk-load-s3access-log.bucket
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  depends_on              = [aws_s3_bucket.bulk-load-s3access-log, aws_s3_bucket_policy.policy-bulk-load-s3access-log-bucket]
}

resource "aws_s3_bucket_policy" "policy-bulk-load-s3access-log-bucket" {
  bucket = aws_s3_bucket.bulk-load-s3access-log.id
  depends_on = [aws_s3_bucket.bulk-load-s3access-log]
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "BulkLoadBucketPolicy"
    Statement = [
      {
        Sid       = "S3BucketSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.bulk-load-s3access-log.arn,
          "${aws_s3_bucket.bulk-load-s3access-log.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}




#Bulk-Load-Access-bucket
resource "aws_s3_bucket" "mace-s3access-log" {
  bucket = "${local.prefix}-mace-s3access-log-${local.suffix}"
  acl    = "log-delivery-write"

  lifecycle {
    prevent_destroy = true
  }

  force_destroy = false

    versioning {
      enabled = true
      #mfa_delete = true
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
  tomap({ "Name" = "${local.prefix}-mace-s3access-log-${local.suffix}" })
  )
}

resource "aws_s3_bucket_public_access_block" "block-public-access-mace-s3access-log" {
  bucket                  = aws_s3_bucket.mace-s3access-log.bucket
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  depends_on              = [aws_s3_bucket.mace-s3access-log, aws_s3_bucket_policy.policy-mace-s3access-log-bucket]
}

resource "aws_s3_bucket_policy" "policy-mace-s3access-log-bucket" {
  bucket = aws_s3_bucket.mace-s3access-log.id
  depends_on = [aws_s3_bucket.mace-s3access-log]
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MaceBucketPolicy"
    Statement = [
      {
        Sid       = "S3BucketSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.mace-s3access-log.arn,
          "${aws_s3_bucket.mace-s3access-log.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}