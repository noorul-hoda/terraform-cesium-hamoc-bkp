//Codepipeline S3 Artifact Bucket
//ECS Codepipeline

resource "aws_s3_bucket" "ecs-pipeline-artifacts" {
  bucket        = "${local.prefix}-ecs-pipeline-artifacts-${local.suffix}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_public_access_block" "ecs-pipeline-artifacts" {
  bucket                  = aws_s3_bucket.ecs-pipeline-artifacts.bucket
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}

resource "aws_codepipeline" "ecs-pipeline" {
  depends_on = [aws_s3_bucket.ecs-pipeline-artifacts]
  name       = "${local.prefix}-ecs-pipeline-${local.suffix}"
  role_arn   = aws_iam_role.ecs-pipeline-role.arn

  artifact_store {
    location = aws_s3_bucket.ecs-pipeline-artifacts.id
    type     = "S3"

    encryption_key {
      id   = data.aws_kms_alias.s3kmskey.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      configuration = {
        ConnectionArn    = "${var.codestar_bitbucket_arn}"
        FullRepositoryId = "${var.ecs-repo_name}"
        BranchName       = "${local.suffix}"
      }
    }
  }

  stage {
    name = "Approve"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        NotificationArn = var.approval_sns_arn
        CustomData      = "Please approve the ECS Fargate deployment on ${local.suffix} environment of project ${local.prefix}"
      }
    }
  }

  stage {
    name = "Build_Docker_Image"

    action {
      name             = "Build_And_PushToECR"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"
      namespace        = "BuildVariables"

      configuration = {
        ProjectName = aws_codebuild_project.ecs-codebuild.name
      }
    }
  }

  stage {
    name = "Deploy_Fargate"

    action {
      name            = "Deploy_to_Fargate"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts  = ["BuildArtifact"]
      version         = "1"
      namespace        = "DeployVariables"
      
      configuration = {
        ClusterName = var.ecs_clustername
        ServiceName = var.ecs_servicename

      }
    }
  }
}
