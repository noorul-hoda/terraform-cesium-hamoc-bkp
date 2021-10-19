//Codepipeline artifact s3 bucket
//SNS Topic
//Fronend/Backend codepipeline

resource "aws_s3_bucket" "frontend_backend-pipeline-artifacts" {
  bucket        = "${local.prefix}-frontend-backend-pipeline-artifacts-${local.suffix}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_backend-pipeline-artifacts" {
  bucket                  = aws_s3_bucket.frontend_backend-pipeline-artifacts.bucket
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}

resource "aws_codepipeline" "frontend_backend-pipeline" {
  depends_on = [aws_s3_bucket.frontend_backend-pipeline-artifacts]
  name       = "${local.prefix}-frontend-backend-pipeline-${local.suffix}"
  role_arn   = aws_iam_role.frontend_backend-pipeline-role.arn

  artifact_store {
    location = aws_s3_bucket.frontend_backend-pipeline-artifacts.id
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
        FullRepositoryId = "${var.repo_name}"
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
        CustomData      = "Please approve the Frontend/Backend deployment on ${local.suffix} environment of project ${local.prefix}"
      }
    }
  }

  stage {
    name = "Backend_Build_And_Deploy"

    action {
      name             = "Lambda_Build_And_Deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"
      namespace        = "BuildVariables"

      configuration = {
        ProjectName = aws_codebuild_project.lambda-codebuild.name
      }
    }
  }

  stage {
    name = "Frontend_Build_And_Deploy"

    action {
      name            = "Frontend_Deploy_Invalidate"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["Frontend_BuildArtifact"]
      version         = "1"
      namespace        = "Frontend_BuildVariables"
      
      configuration = {
        ProjectName = aws_codebuild_project.frontend-codebuild.name
      }
    }
  }
}
