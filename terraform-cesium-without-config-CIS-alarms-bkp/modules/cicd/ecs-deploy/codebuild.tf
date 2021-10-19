//ECS Codebuild

resource "aws_codebuild_project" "ecs-codebuild" {
  name           = "${local.prefix}-ecs-fargate-codebuild-${local.suffix}"
  build_timeout  = "60"
  service_role   = aws_iam_role.ecs-codebuild-role.arn
  encryption_key = data.aws_kms_alias.s3kmskey.arn

  artifacts {
    type      = "CODEPIPELINE"
    name      = "${local.prefix}-ecs-codebuild-${local.suffix}"
    packaging = "ZIP"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = "true"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "REPOSITORY_URI"
      value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
    }

    environment_variable {
      name  = "REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "ECR_IMAGE_NAME"
      value = "${local.prefix}-${var.fargate-ecrname}-${local.suffix}"
    }

    environment_variable {
      name  = "CONTAINER_NAME"
      value = "${local.prefix}-${var.taskdefinition}-${local.suffix}"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.ecs_codebuild_loggroup
      stream_name = "ecs-codebuild-logs"
    }

  }

  source {
    type = "CODEPIPELINE"
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ecs-codebuild-${local.suffix}" }
    )
  )
}
