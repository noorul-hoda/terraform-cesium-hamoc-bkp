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
  db_instance_class = var.db_instance_class
  storage_encrypted = true
  kms_key_id        = data.aws_kms_alias.rds.target_key_arn
  ##

  subnets_priv_id = module.networking.subnets_priv_id
  sg-rds-id       = module.networking.sg-rds-id
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

module "cicd-mgmnt" {
  source = "./modules/cicd/cicd-mgmnt"

  region      = var.region
  profile     = var.profile
  project     = var.project
  owner       = var.owner
  environment = var.environment

  # ecs-pipeline_arn            = module.ecs-deploy.ecs-pipeline_arn
  # front-back-end-pipeline_arn = module.lambda_s3-deploy.front-back-end-pipeline_arn
}

module "lambda_s3-deploy" {
  source          = "./modules/cicd/lambda_s3-deploy"
  region          = var.region
  profile         = var.profile
  project         = var.project
  owner           = var.owner
  environment     = var.environment
  repo_name       = var.repo_name
  api-domain-name = var.api-domain-name

  web-bucket-name                 = module.frontend-core.web-bucket-name
  cf-distribution_id              = module.frontend-core.cf-distribution_id
  codestar-bitbucket-arn          = module.cicd-mgmnt.codestar-bitbucket-arn
  approval_sns_arn                = module.cicd-mgmnt.approval_sns_arn
  lambda_codebuild_loggroup       = module.cicd-mgmnt.lambda_codebuild_loggroup
  frontend_codebuild_loggroup     = module.cicd-mgmnt.frontend_codebuild_loggroup
  lambda_codebuild_loggroup_arn   = module.cicd-mgmnt.lambda_codebuild_loggroup_arn
  frontend_codebuild_loggroup_arn = module.cicd-mgmnt.frontend_codebuild_loggroup_arn
  api-gw-invoke-url               = module.backend.api-gw-invoke-url
}

module "ecs-deploy" {
  source          = "./modules/cicd/ecs-deploy"
  region          = var.region
  profile         = var.profile
  project         = var.project
  owner           = var.owner
  environment     = var.environment
  ecs-repo_name   = var.ecs-repo_name
  taskdefinition  = var.taskdefinition
  fargate-ecrname = var.fargate-ecrname
  api-domain-name = var.api-domain-name

  ecs_clustername            = module.ecs.ecs_clustername
  ecs_servicename            = module.ecs.ecs_servicename
  codestar-bitbucket-arn     = module.cicd-mgmnt.codestar-bitbucket-arn
  approval_sns_arn           = module.cicd-mgmnt.approval_sns_arn
  ecs_codebuild_loggroup     = module.cicd-mgmnt.ecs_codebuild_loggroup
  ecs_codebuild_loggroup_arn = module.cicd-mgmnt.ecs_codebuild_loggroup_arn

}

module "ml_lambda_deploy" {
  source              = "./modules/cicd/ml-lambda-deploy"
  region              = var.region
  profile             = var.profile
  project             = var.project
  owner               = var.owner
  environment         = var.environment
  ml_lambda_repo_name = var.ml_lambda_repo_name
  api-domain-name     = var.api-domain-name

  codestar-bitbucket-arn           = module.cicd-mgmnt.codestar-bitbucket-arn
  approval_sns_arn                 = module.cicd-mgmnt.approval_sns_arn
  ml_lambda_codebuild_loggroup     = module.cicd-mgmnt.ml_lambda_codebuild_loggroup
  ml_lambda_codebuild_loggroup_arn = module.cicd-mgmnt.ml_lambda_codebuild_loggroup_arn
  api-gw-invoke-url                = module.backend.api-gw-invoke-url
  lambda-packages-bucket-name      = module.storage.lambda-packages-bucket-name
}

####################
## Cloudwatch/Management Tools
####################

module "cloudwatch" {
  source      = "./modules/management-tools/cloudwatch"
  region      = var.region
  profile     = var.profile
  project     = var.project
  owner       = var.owner
  environment = var.environment

  db-host-identifier       = module.storage.db-host-identifier
  ecs_alb_arn_suffix       = module.ecs.ecs_alb_arn_suffix
  ecs_alb_tg_arn_suffix    = module.ecs.ecs_alb_tg_arn_suffix
  ecs_servicename          = module.ecs.ecs_servicename
  ecs_clustername          = module.ecs.ecs_clustername
  ec2-etl-instance-id      = module.networking.ec2-etl-instance-id
  bastion-host-instance-id = module.networking.bastion-host-instance-id
  sts-vpn-id               = module.vpn.sts-vpn-id
}
