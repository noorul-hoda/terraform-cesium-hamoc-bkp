//Codepipeline artifact s3 bucket
//SNS Topic
//Fronend/Backend codepipeline

resource "aws_s3_bucket" "ml-lambda-pipeline-artifacts" {
  bucket        = "${local.prefix}-ml-lambda-pipeline-artifacts-${local.suffix}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_public_access_block" "ml-lambda-pipeline-artifacts" {
  bucket                  = aws_s3_bucket.ml-lambda-pipeline-artifacts.bucket
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}

resource "aws_codepipeline" "ml-lambda-pipeline" {
  depends_on = [aws_s3_bucket.ml-lambda-pipeline-artifacts]
  name       = "${local.prefix}-ml-lambda-pipeline-${local.suffix}"
  role_arn   = aws_iam_role.ml-lambda-pipeline-role.arn

  artifact_store {
    location = aws_s3_bucket.ml-lambda-pipeline-artifacts.id
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
        ConnectionArn    = "${var.codestar-bitbucket-arn}"
        FullRepositoryId = "${var.ml_lambda_repo_name}"
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
        CustomData      = "Please approve the ML Lambda deployment on ${local.suffix} environment of project ${local.prefix}"
      }
    }
  }

  stage {
    name = "ML_Lambda_Build_And_Deploy"

    action {
      name             = "ML_Lambda_Build_And_Deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"
      namespace        = "BuildVariables"

      configuration = {
        ProjectName = aws_codebuild_project.ml-lambda-codebuild.name
      }
    }
  }
}
