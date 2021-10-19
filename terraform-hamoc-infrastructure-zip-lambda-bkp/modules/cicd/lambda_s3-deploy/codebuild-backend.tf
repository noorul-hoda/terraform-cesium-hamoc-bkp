//Lambda codebuild

resource "aws_codebuild_project" "lambda-codebuild" {
  name           = "${local.prefix}-lambda-codebuild-${local.suffix}"
  build_timeout  = "60"
  service_role   = aws_iam_role.lambda-codebuild-role.arn
  encryption_key = data.aws_kms_alias.s3kmskey.arn

  artifacts {
    type      = "CODEPIPELINE"
    name      = "${local.prefix}-lambda-codebuild-${local.suffix}"
    packaging = "ZIP"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = "true"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "ALIAS"
      value = local.suffix
    }

    environment_variable {
      name  = "PREFIX"
      value = local.prefix
    }

    environment_variable {
      name  = "SUFFIX"
      value = local.suffix
    }

    environment_variable {
      name  = "LAMBDA_S3_BUCKET"
      value = var.lambda_packages_bucket_name
    }

    environment_variable {
      name  = "API_GW_URL"
      value = "https://${var.api-domain-name}"
    }

  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.lambda_codebuild_loggroup
      stream_name = "lambda-codebuild-logs"
    }

  }

  source {
    type = "CODEPIPELINE"
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-lambda-codebuild-${local.suffix}" }
    )
  )
}
