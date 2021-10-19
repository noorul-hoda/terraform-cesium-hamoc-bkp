//Frontend codebuild

resource "aws_codebuild_project" "frontend-codebuild" {
  name           = "${local.prefix}-frontend-codebuild-${local.suffix}"
  build_timeout  = "60"
  service_role   = aws_iam_role.frontend-codebuild-role.arn
  encryption_key = data.aws_kms_alias.s3kmskey.arn

  artifacts {
    type      = "CODEPIPELINE"
    name      = "${local.prefix}-frontend-codebuild-${local.suffix}"
    packaging = "ZIP"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = "true"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "FRONTEND_BUCKET"
      value = var.web-bucket-name
    }

    environment_variable {
      name  = "CLOUDFRONT_DISTRIBUTION_ID"
      value = var.cf-distribution_id
    }

    environment_variable {
      name  = "REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = local.suffix
    }

    environment_variable {
      name  = "API_GW_URL"
      value = "https://${var.api-domain-name}"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.frontend_codebuild_loggroup
      stream_name = "frontend-codebuild-logs"
    }

  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-frontend.yml"
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-frontend-codebuild-${local.suffix}" }
    )
  )
}
