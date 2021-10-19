####################
## Networking
####################

module "networking" {
  source                  = "./modules/networking"
  region                  = var.region
  profile                 = var.profile
  project                 = var.project
  owner                   = var.owner
  environment             = var.environment
  cidr                    = var.cidr
  pub-subnet              = var.pub-subnet
  priv-subnet             = var.priv-subnet
  myip                    = var.myip
  instance-type           = var.instance-type
  instance-type-etl       = var.instance-type-etl
  alb_whitelist_ipv4-list = var.alb_whitelist_ipv4-list
  alb_whitelist_ipv6-list = var.alb_whitelist_ipv6-list
  enable_flow_log         = true
  flow_log_traffic_type   = "REJECT"

  bulk-load-s3_arn = module.storage.bulk-load-s3_arn
}

module "vpn" {
  source            = "./modules/vpn"
  region            = var.region
  profile           = var.profile
  project           = var.project
  owner             = var.owner
  environment       = var.environment
  cgw-onprem-ip     = var.cgw-onprem-ip
  onprem-cidr-block = var.onprem-cidr-block

  vpc-id              = module.networking.vpc-id
  route_table_pub_id  = module.networking.route_table_pub_id
  route_table_priv_id = module.networking.route_table_priv_id

}

####################
## IAM
####################

module "iam" {
  source      = "./modules/iam"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  ecs_codebuild_loggroup_arn             = module.cw-loggroup-ecs_codebuild.cw_log_group_arn
  ecs_pipeline_artifacts_id              = module.s3-ecs-pipeline-artifacts.s3_bucket_id
  lambda_packages_bucket_name            = module.storage.lambda-packages-bucket-name
  web_bucket_name                        = module.frontend-core.web-bucket-name
  frontend_backend_pipeline_artifacts_id = module.s3-frontend-backend-pipeline-artifacts.s3_bucket_id
  lambda_codebuild_loggroup_arn          = module.cw-loggroup-lambda_codebuild.cw_log_group_arn
  frontend_codebuild_loggroup_arn        = module.cw-loggroup-frontend_codebuild.cw_log_group_arn
  ml_lambda_pipeline_artifacts_id        = module.s3-ml-lambda-pipeline-artifacts.s3_bucket_id
  ml_lambda_codebuild_loggroup_arn       = module.cw-loggroup-ml-lambda-codebuild.cw_log_group_arn

}

####################
## Storage
####################

module "storage" {
  source = "./modules/storage"

  region      = var.region
  profile     = var.profile
  project     = var.project
  owner       = var.owner
  environment = var.environment

  ##RDS
  db-username       = var.db-username
  db-password       = var.db-password
  db-username-etl       = var.db-username-etl
  db-password-etl       = var.db-password-etl
  db_instance_class = var.db_instance_class
  storage_encrypted = true
  kms_key_id        = data.aws_kms_alias.rds.target_key_arn
  ##

  subnets_priv_id       = module.networking.subnets_priv_id
  sg-rds-id             = module.networking.sg-rds-id
  ml-sagemaker-role-arn = module.ml.ml-sagemaker-role-arn
  ml_lambda_role-arn    = module.ml.ml_lambda_role-arn
}

####################
## Frontend
####################

module "frontend-core" {
  source = "./modules/frontend/frontend-core"
  providers = {
    aws              = aws
    aws.acm-virginia = aws.acm-virginia
  }
  region              = var.region
  profile             = var.profile
  project             = var.project
  owner               = var.owner
  environment         = var.environment
  website-domain-main = var.website-domain-main

  wafv2-web-acl-arn = module.wafv2.wafv2-web-acl-arn
  #lambda-edge_qualified_arn = module.lambda_edge.lambda-edge_qualified_arn
  lambda_function_association = [
    {
      event_type   = "viewer-request"
      include_body = false
      lambda_arn   = module.lambda_edge_viewer-request.lambda-edge_qualified_arn
    },
    {
      event_type   = "origin-response"
      include_body = false
      lambda_arn   = module.lambda_edge_origin-response.lambda-edge_qualified_arn
    }
  ]
}

# module "lambda_edge" {
#   source = "./modules/frontend/lambda_edge"
#   providers = {
#     aws.acm-virginia = aws.acm-virginia
#     aws              = aws
#   }
#   region      = var.region
#   profile     = var.profile
#   project     = var.project
#   owner       = var.owner
#   environment = var.environment
# }

module "lambda_edge_viewer-request" {
  source = "./modules/lambda_edge"
  providers = {
    aws = aws.acm-virginia
  }
  lambda-edge-name     = "edge-viewer-request"
  lambda_edge_code_dir = "./lambda_edge_code/viewer-request"
  handler              = "index.handler"

  region      = var.region
  profile     = var.profile
  project     = var.project
  owner       = var.owner
  environment = var.environment
}

module "lambda_edge_origin-response" {
  source = "./modules/lambda_edge"
  providers = {
    aws = aws.acm-virginia
  }
  lambda-edge-name     = "edge-origin-response"
  lambda_edge_code_dir = "./lambda_edge_code/origin-response"
  handler              = "headers.handler"

  region      = var.region
  profile     = var.profile
  project     = var.project
  owner       = var.owner
  environment = var.environment
}

module "wafv2" {
  source = "./modules/frontend/wafv2"
  providers = {
    aws.acm-virginia = aws.acm-virginia
    aws              = aws
  }

  region                 = var.region
  profile                = var.profile
  project                = var.project
  owner                  = var.owner
  environment            = var.environment
  cf_whitelist_ipv4-list = var.cf_whitelist_ipv4-list
  cf_whitelist_ipv6-list = var.cf_whitelist_ipv6-list
  cf_blacklist_ipv4-list = var.cf_blacklist_ipv4-list
  cf_blacklist_ipv6-list = var.cf_blacklist_ipv6-list
}

####################
## Backend
####################

module "backend" {
  source = "./modules/backend"

  region              = var.region
  profile             = var.profile
  project             = var.project
  owner               = var.owner
  environment         = var.environment
  lambda_list         = var.lambda_list
  lambda_for_api      = var.lambda_for_api
  db-username         = var.db-username
  db-password         = var.db-password
  website-domain-main = var.website-domain-main
  api-domain-name     = var.api-domain-name
  ecs-domain-name     = var.ecs-domain-name

  subnets_priv_id          = module.networking.subnets_priv_id
  sg-lambda-id             = module.networking.sg-lambda-id
  cognito-user-pool_arn    = module.frontend-core.cognito-user-pool_arn
  ecs_alb_dns_name         = module.ecs.ecs_alb_dns_name
  db-host-address          = module.storage.db-host-address
  update-routine-bucket-id = module.storage.update-routine-bucket-id
  sagemaker-bucket-id      = module.storage.sagemaker-bucket-id
  acm-website-cert-arn     = module.ecs.acm-website-cert-arn
}

####################
## ECS Faragate
####################

module "ecs" {
  source                  = "./modules/ecs-fargate"
  region                  = var.region
  profile                 = var.profile
  project                 = var.project
  owner                   = var.owner
  environment             = var.environment
  fargate-ecrname         = var.fargate-ecrname
  cluster-name            = var.cluster-name
  ecs-service             = var.ecs-service
  taskdefinition          = var.taskdefinition
  website-domain-main     = var.website-domain-main
  ecs-domain-name         = var.ecs-domain-name
  alb_blacklist_ipv4-list = var.alb_blacklist_ipv4-list
  alb_blacklist_ipv6-list = var.alb_blacklist_ipv6-list

  sg-ecs-id                    = module.networking.sg-ecs-id
  sg-alb-id                    = module.networking.sg-alb-id
  subnets_pub_id               = module.networking.subnets_pub_id
  subnets_priv_id              = module.networking.subnets_priv_id
  vpc-id                       = module.networking.vpc-id
  rds-postgre-address-ssm_arn  = module.storage.rds-postgre-address-ssm_arn
  rds-postgre-username-ssm_arn = module.storage.rds-postgre-username-ssm_arn
  rds-postgre-password-ssm_arn = module.storage.rds-postgre-password-ssm_arn
}

####################
## ML/Sagemaker
####################

module "ml" {
  source = "./modules/ml"

  region          = var.region
  profile         = var.profile
  project         = var.project
  owner           = var.owner
  environment     = var.environment
  ml_lambda_list  = var.ml_lambda_list
  db-username     = var.db-username
  db-password     = var.db-password
  api-domain-name = var.api-domain-name
  ecs-domain-name = var.ecs-domain-name

  sg-sagemaker-id            = module.networking.sg-sagemaker-id
  subnets_priv_id            = module.networking.subnets_priv_id
  sg-lambda-id               = module.networking.sg-lambda-id
  ecs_alb_dns_name           = module.ecs.ecs_alb_dns_name
  db-host-address            = module.storage.db-host-address
  sagemaker-bucket-arn       = module.storage.sagemaker-bucket-arn
  sagemaker-bucket-id        = module.storage.sagemaker-bucket-id
  update-routine-bucket-id   = module.storage.update-routine-bucket-id
  lambda-apigw-access-id     = module.backend.lambda-apigw-access-id
  lambda-apigw-access-secret = module.backend.lambda-apigw-access-secret
}

####################
## CICD
####################

##Codestar Connection

module "codestarconnection" {
  source      = "./modules/codestarconnection"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name          = "bitbucket"
  provider_type = "Bitbucket"
}

##SNS

module "sns-deploy-approval" {
  source      = "./modules/sns"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = "deploy-approval"
}

module "sns-codepipeline-updates" {
  source      = "./modules/sns"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = "codepipeline-updates"

  sns_topic_policy_json = data.template_file.codepipeline-updates_sns_policy.rendered
}

##CW Rule for CICD Notifications

module "cw-event-rule-pipelineupdates" {
  source      = "./modules/cloudwatch_event"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name                      = "codepipeline-updates"
  cw_event_rule_description = "Capture changes for ${local.prefix}-${local.suffix} pipelines"
  cw_event_rule_pattern     = <<PATTERN
{
  "source": [
    "aws.codepipeline"
  ],
  "detail-type": [
    "CodePipeline Pipeline Execution State Change"
  ]
}
PATTERN
  arn                       = module.sns-codepipeline-updates.sns_topic_arn
  input_transformer = {
    input_paths = {
      accounts = "$.account",
      branch   = "$.detail.referenceName",
      pipeline = "$.detail.pipeline",
      state    = "$.detail.state"

    }
    input_template = "\"CICD CodePipeline for Name: <pipeline> has <state> for Account: ${local.prefix} ${local.suffix} environment\""

  }
}

###ECS CICD 

module "cw-loggroup-ecs_codebuild" {
  source      = "./modules/cw-log-group"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name              = "ecs-codebuild"
  retention_in_days = "60"
}

module "s3-ecs-pipeline-artifacts" {
  source = "./modules/s3/"

  bucket                  = "${local.prefix}-ecs-pipeline-artifacts-${local.suffix}"
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  force_destroy           = true
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ecs-pipeline-artifacts-${local.suffix}" }
    )
  )
}

resource "aws_s3_bucket_policy" "policy-ecs-pipeline-artifacts-bucket" {
  bucket     = module.s3-ecs-pipeline-artifacts.s3_bucket_id
  depends_on = [module.s3-ecs-pipeline-artifacts]
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "ECSPipelineArtifactsPolicy"
    Statement = [
      {
        Sid       = "S3BucketSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          module.s3-ecs-pipeline-artifacts.s3_bucket_arn,
          "${module.s3-ecs-pipeline-artifacts.s3_bucket_arn}/*",
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

## ECS Codebuild

module "ecs-fargate-codebuild" {
  source      = "./modules/codebuild"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name             = "ecs-fargate-codebuild"
  encryption_key   = data.aws_kms_alias.s3.arn
  service_role_arn = module.iam.ecs_codebuild_role_arn

  artifacts = {
    type      = "CODEPIPELINE"
    name      = "${local.prefix}-ecs-codebuild-${local.suffix}"
    packaging = "ZIP"
  }

  vpc_config = {
    vpc_id             = module.networking.vpc-id
    subnets            = flatten([module.networking.subnets_priv_id])
    security_group_ids = [module.networking.sg_codebuild_id]
  }

  cb-source = {
    type = "CODEPIPELINE"
  }

  logs_config = {
    cloudwatch_logs = {
      group_name  = module.cw-loggroup-ecs_codebuild.cw_log_group_name
      stream_name = "ecs-codebuild-logs"
    }
  }

  environment_variable = [
    {
      name  = "REPOSITORY_URI"
      value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
      type  = "PLAINTEXT"
    },
    {
      name  = "REGION"
      value = data.aws_region.current.name
      type  = "PLAINTEXT"
    },
    {
      name  = "ECR_IMAGE_NAME"
      value = "${local.prefix}-${var.fargate-ecrname}-${local.suffix}"
      type  = "PLAINTEXT"
    },
    {
      name  = "CONTAINER_NAME"
      value = "${local.prefix}-${var.taskdefinition}-${local.suffix}"
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_NAME"
      value = "${local.prefix}_db_${local.suffix}"
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_USER"
      value = var.db-username
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_PASSWORD"
      value = var.db-password
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_HOST"
      value = module.storage.db-host-address
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_PORT"
      value = "5432"
      type  = "PLAINTEXT"
    }
  ]
}

##ECS Codepipeline

module "ecs-pipeline" {
  source      = "./modules/codepipeline"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name     = "ecs-pipeline"
  role_arn = module.iam.ecs_pipeline_role_arn

  artifact_store = {
    location = module.s3-ecs-pipeline-artifacts.s3_bucket_id
    type     = "S3"
  }

  encryption_key = {
    id   = data.aws_kms_alias.s3.arn
    type = "KMS"
  }

  stages = [{
    name = "Source"
    action = {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      configuration = {
        ConnectionArn    = module.codestarconnection.connection_arn
        FullRepositoryId = "${var.ecs-repo_name}"
        BranchName       = "${local.suffix}"
      }
    }
    },
    {
      name = "Approve"
      action = {
        name     = "Approval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"

        configuration = {
          NotificationArn = module.sns-deploy-approval.sns_topic_arn
          CustomData      = "Please approve the ECS Fargate deployment on ${local.suffix} environment of project ${local.prefix}"
        }
      }
    },
    {
      name = "Build_Docker_Image"
      action = {
        name             = "Build_And_PushToECR"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = ["BuildArtifact"]
        version          = "1"
        namespace        = "BuildVariables"

        configuration = {
          ProjectName = module.ecs-fargate-codebuild.codebuild_name
        }
      }
    },
    {
      name = "Deploy_Fargate"
      action = {
        name            = "Deploy_to_Fargate"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "ECS"
        input_artifacts = ["BuildArtifact"]
        version         = "1"
        namespace       = "DeployVariables"

        configuration = {
          ClusterName = module.ecs.ecs_clustername
          ServiceName = module.ecs.ecs_servicename

        }
      }
    }
  ]
}


###Frontend/Backend CICD 

module "cw-loggroup-lambda_codebuild" {
  source      = "./modules/cw-log-group"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name              = "lambda-codebuild"
  retention_in_days = "60"
}

module "cw-loggroup-frontend_codebuild" {
  source      = "./modules/cw-log-group"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name              = "frontend-codebuild"
  retention_in_days = "60"
}

module "s3-frontend-backend-pipeline-artifacts" {
  source = "./modules/s3/"

  bucket                  = "${local.prefix}-frontend-backend-pipeline-artifacts-${local.suffix}"
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  force_destroy           = true
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  /*
  versioning = {
    enable = true
    encryption = true
  }*/

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-frontend-backend-pipeline-artifacts-${local.suffix}" }
    )
  )
}

resource "aws_s3_bucket_policy" "policy-frontend-backend-pipeline-artifacts" {
  bucket     = module.s3-frontend-backend-pipeline-artifacts.s3_bucket_id
  depends_on = [module.s3-frontend-backend-pipeline-artifacts]
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "FrontendBackendPipelineArtifactsPolicy"
    Statement = [
      {
        Sid       = "S3BucketSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          module.s3-frontend-backend-pipeline-artifacts.s3_bucket_arn,
          "${module.s3-frontend-backend-pipeline-artifacts.s3_bucket_arn}/*",
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

## Lambda Codebuild

module "lambda-codebuild" {
  source      = "./modules/codebuild"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name             = "lambda-codebuild"
  encryption_key   = data.aws_kms_alias.s3.arn
  service_role_arn = module.iam.lambda_codebuild_role_arn

  artifacts = {
    type      = "CODEPIPELINE"
    name      = "${local.prefix}-lambda-codebuild-${local.suffix}"
    packaging = "ZIP"
  }

  vpc_config = {
    vpc_id             = module.networking.vpc-id
    subnets            = flatten([module.networking.subnets_priv_id])
    security_group_ids = [module.networking.sg_codebuild_id]
  }

  cb-source = {
    type = "CODEPIPELINE"
  }

  logs_config = {
    cloudwatch_logs = {
      group_name  = module.cw-loggroup-lambda_codebuild.cw_log_group_name
      stream_name = "lambda-codebuild-logs"
    }
  }

  environment_variable = [
    {
      name  = "REGION"
      value = data.aws_region.current.name
      type  = "PLAINTEXT"
    },
    {
      name  = "ALIAS"
      value = local.suffix
      type  = "PLAINTEXT"
    },
    {
      name  = "PREFIX"
      value = local.prefix
      type  = "PLAINTEXT"
    },
    {
      name  = "SUFFIX"
      value = local.suffix
      type  = "PLAINTEXT"
    },
    {
      name  = "REPOSITORY_URI"
      value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
      type  = "PLAINTEXT"
    },
    {
      name  = "API_GW_URL"
      value = "https://${var.api-domain-name}"
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_NAME"
      value = "${local.prefix}_db_${local.suffix}"
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_USER"
      value = var.db-username
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_PASSWORD"
      value = var.db-password
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_HOST"
      value = module.storage.db-host-address
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_PORT"
      value = "5432"
      type  = "PLAINTEXT"
    }
  ]
}

## Frontend Codebuild

module "frontend-codebuild" {
  source      = "./modules/codebuild"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name             = "frontend-codebuild"
  encryption_key   = data.aws_kms_alias.s3.arn
  service_role_arn = module.iam.frontend_codebuild_role_arn

  artifacts = {
    type      = "CODEPIPELINE"
    name      = "${local.prefix}-frontend-codebuild-${local.suffix}"
    packaging = "ZIP"
  }

  vpc_config = {
    vpc_id             = module.networking.vpc-id
    subnets            = flatten([module.networking.subnets_priv_id])
    security_group_ids = [module.networking.sg_codebuild_id]
  }

  cb-source = {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-frontend.yml"
  }

  logs_config = {
    cloudwatch_logs = {
      group_name  = module.cw-loggroup-frontend_codebuild.cw_log_group_name
      stream_name = "frontend-codebuild-logs"
    }
  }

  environment_variable = [
    {
      name  = "FRONTEND_BUCKET"
      value = module.frontend-core.web-bucket-name
      type  = "PLAINTEXT"
    },
    {
      name  = "CLOUDFRONT_DISTRIBUTION_ID"
      value = module.frontend-core.cf-distribution_id
      type  = "PLAINTEXT"
    },

    {
      name  = "COGNITO_USER_POOL_ID"
      value = module.frontend-core.user_pool_id
      type  = "PLAINTEXT"
    },
    {
      name  = "COGNITO_APP_CLIENT_ID"
      value = module.frontend-core.user_pool_client_id
      type  = "PLAINTEXT"
    },

    {
      name  = "REGION"
      value = data.aws_region.current.name
      type  = "PLAINTEXT"
    },
    {
      name  = "ENVIRONMENT"
      value = local.suffix
      type  = "PLAINTEXT"
    },
    {
      name  = "API_GW_URL"
      value = "https://${var.api-domain-name}"
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_NAME"
      value = "${local.prefix}_db_${local.suffix}"
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_USER"
      value = var.db-username
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_PASSWORD"
      value = var.db-password
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_HOST"
      value = module.storage.db-host-address
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_PORT"
      value = "5432"
      type  = "PLAINTEXT"
    }
  ]
}

##Frontend/Backend Codepipeline

module "frontend-backend-pipeline" {
  source      = "./modules/codepipeline"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name     = "frontend-backend-pipeline"
  role_arn = module.iam.frontend_backend_pipeline_role_arn

  artifact_store = {
    location = module.s3-frontend-backend-pipeline-artifacts.s3_bucket_id
    type     = "S3"
  }

  encryption_key = {
    id   = data.aws_kms_alias.s3.arn
    type = "KMS"
  }

  stages = [
    {
      name = "Source"

      action = {
        name             = "Source"
        category         = "Source"
        owner            = "AWS"
        provider         = "CodeStarSourceConnection"
        version          = "1"
        output_artifacts = ["SourceArtifact"]
        configuration = {
          ConnectionArn    = module.codestarconnection.connection_arn
          FullRepositoryId = "${var.repo_name}"
          BranchName       = "${local.suffix}"
        }
      }
    },
    {
      name = "Approve"
      action = {
        name     = "Approval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"

        configuration = {
          NotificationArn = module.sns-deploy-approval.sns_topic_arn
          CustomData      = "Please approve the Frontend/Backend deployment on ${local.suffix} environment of project ${local.prefix}"
        }
      }
    },
    {
      name = "Backend_Build_And_Deploy"
      action = {
        name             = "Lambda_Build_And_Deploy"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = ["BuildArtifact"]
        version          = "1"
        namespace        = "BuildVariables"

        configuration = {
          ProjectName = module.lambda-codebuild.codebuild_name
        }
      }
    },
    {
      name = "Frontend_Build_And_Deploy"
      action = {
        name             = "Frontend_Deploy_Invalidate"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = ["Frontend_BuildArtifact"]
        version          = "1"
        namespace        = "Frontend_BuildVariables"

        configuration = {
          ProjectName = module.frontend-codebuild.codebuild_name
        }
      }
    }
  ]
}

###ML CICD 

module "cw-loggroup-ml-lambda-codebuild" {
  source      = "./modules/cw-log-group"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name              = "ml-lambda-codebuild"
  retention_in_days = "60"
}

module "s3-ml-lambda-pipeline-artifacts" {
  source = "./modules/s3/"

  bucket                  = "${local.prefix}-ml-lambda-pipeline-artifacts-${local.suffix}"
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  force_destroy           = true
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }


  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ml-lambda-pipeline-artifacts-${local.suffix}" }
    )
  )
}

resource "aws_s3_bucket_policy" "policy-ml-lambda-pipeline-artifacts" {
  bucket     = module.s3-ml-lambda-pipeline-artifacts.s3_bucket_id
  depends_on = [module.s3-ml-lambda-pipeline-artifacts]
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MlLambdaPipelineArtifactsPolicy"
    Statement = [
      {
        Sid       = "S3BucketSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          module.s3-ml-lambda-pipeline-artifacts.s3_bucket_arn,
          "${module.s3-ml-lambda-pipeline-artifacts.s3_bucket_arn}/*",
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

## ML Lambda Codebuild

module "ml-lambda-codebuild" {
  source      = "./modules/codebuild"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name             = "ml-lambda-codebuild"
  encryption_key   = data.aws_kms_alias.s3.arn
  service_role_arn = module.iam.ml_lambda_codebuild_role_arn

  artifacts = {
    type      = "CODEPIPELINE"
    name      = "${local.prefix}-ml-lambda-codebuild-${local.suffix}"
    packaging = "ZIP"
  }

  vpc_config = {
    vpc_id             = module.networking.vpc-id
    subnets            = flatten([module.networking.subnets_priv_id])
    security_group_ids = [module.networking.sg_codebuild_id]
  }

  cb-source = {
    type = "CODEPIPELINE"
  }

  logs_config = {
    cloudwatch_logs = {
      group_name  = module.cw-loggroup-ml-lambda-codebuild.cw_log_group_name
      stream_name = "ml-lambda-codebuild-logs"
    }
  }

  environment_variable = [
    {
      name  = "REGION"
      value = data.aws_region.current.name
      type  = "PLAINTEXT"
    },
    {
      name  = "ALIAS"
      value = local.suffix
      type  = "PLAINTEXT"
    },
    {
      name  = "PREFIX"
      value = local.prefix
      type  = "PLAINTEXT"
    },
    {
      name  = "SUFFIX"
      value = local.suffix
      type  = "PLAINTEXT"
    },
    {
      name  = "LAMBDA_S3_BUCKET"
      value = module.storage.lambda-packages-bucket-name
      type  = "PLAINTEXT"
    },
    {
      name  = "API_GW_URL"
      value = "https://${var.api-domain-name}"
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_NAME"
      value = "${local.prefix}_db_${local.suffix}"
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_USER"
      value = var.db-username
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_PASSWORD"
      value = var.db-password
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_HOST"
      value = module.storage.db-host-address
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_PORT"
      value = "5432"
      type  = "PLAINTEXT"
    }
  ]
}

## ML Lambda Pipeline

module "ml-lambda-pipeline" {
  source      = "./modules/codepipeline"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name     = "ml-lambda-pipeline"
  role_arn = module.iam.ml_lambda_pipeline_role_arn

  artifact_store = {
    location = module.s3-ml-lambda-pipeline-artifacts.s3_bucket_id
    type     = "S3"
  }

  encryption_key = {
    id   = data.aws_kms_alias.s3.arn
    type = "KMS"
  }

  stages = [
    {
      name = "Source"
      action = {
        name             = "Source"
        category         = "Source"
        owner            = "AWS"
        provider         = "CodeStarSourceConnection"
        version          = "1"
        output_artifacts = ["SourceArtifact"]

        configuration = {
          ConnectionArn    = module.codestarconnection.connection_arn
          FullRepositoryId = "${var.ml_lambda_repo_name}"
          BranchName       = "${local.suffix}"
        }
      }
    },
    {
      name = "Approve"
      action = {
        name     = "Approval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"

        configuration = {
          NotificationArn = module.sns-deploy-approval.sns_topic_arn
          CustomData      = "Please approve the ML Lambda deployment on ${local.suffix} environment of project ${local.prefix}"
        }
      }
    },
    {
      name = "ML_Lambda_Build_And_Deploy"
      action = {
        name             = "ML_Lambda_Build_And_Deploy"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = ["BuildArtifact"]
        version          = "1"
        namespace        = "BuildVariables"

        configuration = {
          ProjectName = module.ml-lambda-codebuild.codebuild_name
        }
      }
    }
  ]
}

####################
## Monitoring/Audit
####################

module "cloudtrail" {
  source      = "./modules/cloudtrail"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector = [{
    read_write_type           = "All"
    include_management_events = true

    data_resource = [{
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
      },
      {
        type   = "AWS::S3::Object"
        values = ["arn:aws:s3:::"]
      }
    ]
  }]

  logging = {
    target_bucket = module.s3-cloudtrail-s3access-log.s3_bucket_id
  }

}

module "s3-cloudtrail-s3access-log" {
  source = "./modules/s3/"

  bucket                  = "${local.prefix}-cloudtrail-s3access-log-${local.suffix}"
  acl                     = "log-delivery-write"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning = {
    enabled    = true
    mfa_delete = true
  }

  /*

  lifecycle_rule = [
    {
      id      = "expire_all_files_60_days"
      enabled = true

      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        }
      ]

      expiration = {
        days = 60
      }
    }
  ]
*/

  force_destroy = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-cloudtrail-s3access-log-${local.suffix}" }
    )
  )
}


resource "aws_s3_bucket_policy" "policy-cloudtrail-s3access-log" {
  bucket     = module.s3-cloudtrail-s3access-log.s3_bucket_id
  depends_on = [module.s3-cloudtrail-s3access-log]
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "CloudtrailS3AccessLogPolicy"
    Statement = [
      {
        Sid       = "S3BucketSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          module.s3-cloudtrail-s3access-log.s3_bucket_arn,
          "${module.s3-cloudtrail-s3access-log.s3_bucket_arn}/*",
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

####################
## Cloudwatch/Management Tools/Alarms SNS
####################

## SNS Alerts

module "sns-alerts" {
  source      = "./modules/sns"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = "Alerts"
}

## ECS Alarms

module "cw-alarm-ALB_Healthy_host_count" {

  source      = "./modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "ECS_App_ALB_Healthy_host_count"
  alarm_description         = "Healthy host count for ECS Application less than desired count ${local.suffix == "prod" ? 2 : 1}"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = local.suffix == "prod" ? 2 : 1
  treat_missing_data        = "breaching"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    LoadBalancer = module.ecs.ecs_alb_arn_suffix
    TargetGroup  = module.ecs.ecs_alb_tg_arn_suffix
  }
}


module "cw-alarm-ECS_App-High_Cpu" {

  source      = "./modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "ECS_App-High_Cpu"
  alarm_description         = "ECS_App CPU above 60"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "60.0"
  treat_missing_data        = "breaching"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    ServiceName = module.ecs.ecs_servicename
    ClusterName = module.ecs.ecs_clustername
  }
}

module "cw-alarm-ECS_App-High_Memory" {

  source      = "./modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "ECS_App-High_Memory"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "60.0"
  treat_missing_data        = "breaching"
  alarm_description         = "ECS_App memory above 60"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    ServiceName = module.ecs.ecs_servicename
    ClusterName = module.ecs.ecs_clustername
  }
}

## RDS Alarms

module "cw-alarm-RDS-High_CPU" {

  source      = "./modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "RDS-High_CPU"
  alarm_description         = "RDS CPU above 60"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "60.0"
  treat_missing_data        = "breaching"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    DBInstanceIdentifier = module.storage.db-host-identifier
  }
}

module "cw-alarm-RDS-Low_Storage_Space" {

  source      = "./modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "RDS-Low_Storage_Space"
  alarm_description         = "RDS Low Storage Space < 20GB"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "FreeStorageSpace"
  namespace                 = "AWS/RDS"
  period                    = "60"
  statistic                 = "Minimum"
  threshold                 = "20000000000.0"
  treat_missing_data        = "breaching"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    DBInstanceIdentifier = module.storage.db-host-identifier
  }
}

#RDS Events
resource "aws_db_event_subscription" "default" {
  name      = "${local.prefix}-rds-event-sub-${local.suffix}"
  sns_topic = module.sns-alerts.sns_topic_arn
}

## Bastion Alarms

module "cw-alarm-Bastion-Host-High_CPU" {

  source      = "./modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "Bastion-Host-High_CPU"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "60"
  treat_missing_data        = "breaching"
  alarm_description         = "Bastion host CPU above 60"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    InstanceId = module.networking.bastion-host-instance-id
  }
}

module "cw-alarm-Bastion-Host-Status_Check_Fail" {

  source      = "./modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "Bastion-Host-Status_Check_Fail"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1.0"
  treat_missing_data        = "breaching"
  alarm_description         = "Bastion host Status Check Fail"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    InstanceId = module.networking.bastion-host-instance-id
  }
}

## EC2 ETL Alarms

module "cw-alarm-EC2-ETL-High_CPU" {

  source      = "./modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "EC2-ETL-High_CPU"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "60"
  treat_missing_data        = "breaching"
  alarm_description         = "EC2-ETL CPU above 60"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    InstanceId = module.networking.ec2-etl-instance-id
  }
}

module "cw-alarm-EC2-ETL-Status_Check_Fail" {

  source      = "./modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "EC2-ETL-Status_Check_Fail"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1.0"
  treat_missing_data        = "breaching"
  alarm_description         = "EC2-ETL Status Check Fail"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    InstanceId = module.networking.ec2-etl-instance-id
  }
}

## VPN Alarms

module "cw-alarm-VPN-Tunnel_Down" {

  source      = "./modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  create_metric_alarm       = true
  alarm_name                = "VPN-Tunnel_Down"
  alarm_description         = "Site to Site VPN Tunnel Down"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TunnelState"
  namespace                 = "AWS/VPN"
  period                    = "300"
  statistic                 = "Maximum"
  threshold                 = "0"
  treat_missing_data        = "breaching"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    VpnId = module.vpn.sts-vpn-id
  }
}

####################
## AWS Config
####################

module "sns-config-alerts" {
  source      = "./modules/sns"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = "config-alerts"

  sns_topic_policy_json = data.template_file.aws_config_sns_policy.rendered
}

module "s3-awsconfig" {
  source = "./modules/s3/"

  bucket                  = "${local.prefix}-awsconfig-${local.suffix}"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }


  versioning = {
    enabled    = true
    mfa_delete = true
  }

  /*

  lifecycle_rule = [
    {
      id      = "expire_all_files_60_days"
      enabled = true

      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        }
      ]

      expiration = {
        days = 60
      }
    }
  ]
*/

  force_destroy = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-awsconfig-${local.suffix}" }
    )
  )
}

resource "aws_s3_bucket_policy" "policy-awsconfig" {
  bucket     = module.s3-awsconfig.s3_bucket_id
  depends_on = [module.s3-awsconfig]
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "ECSPipelineArtifactsPolicy"
    Statement = [
      {
        Sid       = "S3BucketSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          module.s3-awsconfig.s3_bucket_arn,
          "${module.s3-awsconfig.s3_bucket_arn}/*",
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

module "aws_config" {
  source      = "./modules/aws_config"
  project     = var.project
  owner       = var.owner
  environment = var.environment

  config_logs_bucket   = module.s3-awsconfig.s3_bucket_id
  config_sns_topic_arn = module.sns-config-alerts.sns_topic_arn
}

####################
## CIS Alarms
####################

module "cis-alarms" {
  source      = "./modules/cis-alarms"
  project     = var.project
  owner       = var.owner
  environment = var.environment

  log_group_name = module.cloudtrail.cloudwatch_log_group_name
  alarm_actions  = [module.sns-cis-alarms.sns_topic_arn]
}

module "sns-cis-alarms" {
  source      = "./modules/sns"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = "CIS-Alarms"
}