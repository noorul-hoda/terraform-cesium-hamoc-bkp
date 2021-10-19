####################
## ACM
####################

module "acm" {
  source      = "../../modules/acm"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name                      = "acm-website-cert"
  hosted_zone_domain        = var.website-domain-main
  domain_name               = var.website-domain-main
  subject_alternative_names = [var.ecs-domain-name, "*.${var.ecs-domain-name}", "*.${var.website-domain-main}"]
}

module "acm-nvirginia" {
  source = "../../modules/acm"
  providers = {
    aws = aws.acm-virginia
  }
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name                      = "acm-website-cert-nvirginia"
  hosted_zone_domain        = var.website-domain-main
  domain_name               = var.website-domain-main
  subject_alternative_names = [var.ecs-domain-name, "*.${var.ecs-domain-name}", "*.${var.website-domain-main}"]
}

####################
## Networking
####################

module "key_pair" {
  source     = "../../modules/key-pair"
  key_name   = local.suffix
  public_key = file("./ssh-keys/${local.suffix}.pub")
}

module "networking" {
  source                  = "../../modules/networking"
  region                  = var.region
  project                 = var.project
  owner                   = var.owner
  environment             = var.environment
  cidr                    = var.cidr
  pub-subnet              = var.pub-subnet
  priv-subnet             = var.priv-subnet
  single_nat_gateway      = var.single_nat_gateway
  alb_whitelist_ipv4-list = var.alb_whitelist_ipv4-list
  alb_whitelist_ipv6-list = var.alb_whitelist_ipv6-list
  instance_ami            = data.aws_ami.ami-london.id
  instance_type           = "t2.micro"
  allowed_range           = var.bastion_allowed_range
  enable_flow_log         = true
  flow_log_traffic_type   = "REJECT"

  key_name  = module.key_pair.key_pair_key_name
  subnet_id = module.networking.subnets_pub_id[1]

}

####################
## Databases
####################

module "rds" {
  source = "../../modules/rds"

  region                  = var.region
  project                 = var.project
  owner                   = var.owner
  environment             = var.environment
  rds_name                = "rds-postgres"
  db-username             = var.db-username
  db-password             = var.db-password
  db_instance_class       = var.db_instance_class
  engine                  = "postgres"
  engine_version          = "12.5"
  storage_type            = "gp2"
  allocated_storage       = "50"
  max_allocated_storage   = "200"
  storage_encrypted       = true
  kms_key_id              = data.aws_kms_alias.rds.target_key_arn
  backup_retention_period = "1"
  skip_final_snapshot     = true
  multi_az                = false
  apply_immediately       = true
  sns_topic               = module.sns-alerts.sns_topic_arn

  subnet_ids             = flatten([module.networking.subnets_priv_id])
  vpc_id                 = module.networking.vpc_id
  availability_zone      = element(data.aws_availability_zones.available.names, 1)
  vpc_security_group_ids = [module.networking.sg_rds_id]
}

module "neptune" {
  source                          = "../../modules/neptune"
  region                          = var.region
  project                         = var.project
  owner                           = var.owner
  environment                     = var.environment
  name                            = "neptune"
  instance_class                  = var.neptune_instance_class
  cluster_backup_retention_period = "1"

  vpc_id                 = module.networking.vpc_id
  subnet_ids             = flatten([module.networking.subnets_priv_id])
  vpc_security_group_ids = [module.networking.sg_neptune_id]
  parameter = [
    {
      name  = "neptune_enable_audit_log"
      value = 1
    }
  ]
}

module "dynamodb" {
  source      = "../../modules/dynamodb"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name     = "hamoc-table"
  hash_key = "UserId"
}


####################
## Frontend
####################

module "frontend" {
  source = "../../modules/frontend"
  providers = {
    aws              = aws
    aws.acm-virginia = aws.acm-virginia
  }
  region               = var.region
  project              = var.project
  owner                = var.owner
  environment          = var.environment
  website-domain-main  = var.website-domain-main
  web-bucket           = "web-bucket"
  wafv2_web_acl_arn    = module.wafv2.wafv2_web_acl_arn
  acm_website_cert_arn = module.acm-nvirginia.acm_website_cert_arn
}

module "wafv2" {
  source = "../../modules/wafv2"
  providers = {
    aws = aws.acm-virginia
  }

  region                 = var.region
  project                = var.project
  owner                  = var.owner
  environment            = var.environment
  name                   = "frontend"
  cf_whitelist_ipv4-list = var.cf_whitelist_ipv4-list
  cf_whitelist_ipv6-list = var.cf_whitelist_ipv6-list
  cf_blacklist_ipv4-list = var.cf_blacklist_ipv4-list
  cf_blacklist_ipv6-list = var.cf_blacklist_ipv6-list
}

####################
## Cognito
####################

module "cognito" {
  source = "../../modules/cognito"
  depends_on = [
    module.frontend
  ]
  region               = var.region
  project              = var.project
  owner                = var.owner
  environment          = var.environment
  website-domain-main  = var.website-domain-main
  acm_website_cert_arn = module.acm-nvirginia.acm_website_cert_arn
}

####################
## ElasticSearch
####################

module "elasticsearch" {
  source = "../../modules/elasticsearch"

  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name               = "es"
  instance_type      = var.es_instance_type
  instance_count     = "1"
  ebs_enabled        = "true"
  volume_size        = "10"
  enable_encrypt     = true
  kms_key_id         = data.aws_kms_alias.es.target_key_arn
  subnet_ids         = [module.networking.subnets_priv_id[1]]
  security_group_ids = [module.networking.sg_elasticsearch_id]
}

####################
## Storage
####################

module "s3-landing" {
  source = "../../modules/s3/"

  bucket                  = "${local.prefix}-landing-${local.suffix}"
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "Expire_Non_Current_Versions"
      enabled = "true"

      noncurrent_version_expiration = {
        days = 15
      }
  }]

  force_destroy = false

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-landing-${local.suffix}" }
    )
  )

}

module "s3-raw" {
  source = "../../modules/s3/"

  bucket                  = "${local.prefix}-raw-${local.suffix}"
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "Expire_Non_Current_Versions"
      enabled = "true"

      noncurrent_version_expiration = {
        days = 15
      }
  }]

  force_destroy = false

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-raw-${local.suffix}" }
    )
  )

}

module "s3-compute" {
  source = "../../modules/s3/"

  bucket                  = "${local.prefix}-compute-${local.suffix}"
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "Expire_Non_Current_Versions"
      enabled = "true"

      noncurrent_version_expiration = {
        days = 15
      }
  }]

  force_destroy = false

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-compute-${local.suffix}" }
    )
  )

}

module "s3-analytics" {
  source = "../../modules/s3/"

  bucket                  = "${local.prefix}-analytics-${local.suffix}"
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "Expire_Non_Current_Versions"
      enabled = "true"

      noncurrent_version_expiration = {
        days = 15
      }
  }]

  force_destroy = false

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-analytics-${local.suffix}" }
    )
  )

}

module "s3-lambda-packages" {
  source = "../../modules/s3/"

  bucket                  = "${local.prefix}-lambda-packages-${local.suffix}"
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  force_destroy = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-lambda-packages-${local.suffix}" }
    )
  )

}

####################
## ECS Fargate
####################

module "ecs" {
  source                  = "../../modules/ecs-fargate"
  region                  = var.region
  project                 = var.project
  owner                   = var.owner
  environment             = var.environment
  name                    = "ecs"
  task_cpu                = "256"
  task_memory             = "512"
  enable_access_logs      = true
  certificate_arn         = module.acm.acm_website_cert_arn
  fargate-ecrname         = var.fargate-ecrname
  cluster-name            = var.cluster-name
  ecs-service             = var.ecs-service
  taskdefinition          = var.taskdefinition
  alb_blacklist_ipv4-list = var.alb_blacklist_ipv4-list
  alb_blacklist_ipv6-list = var.alb_blacklist_ipv6-list
  website-domain-main     = var.website-domain-main
  ecs-domain-name         = var.ecs-domain-name

  alb_subnets         = flatten(["${module.networking.subnets_pub_id}"])
  ecs_subnets         = flatten(["${module.networking.subnets_priv_id}"])
  ecs_security_groups = [module.networking.sg_ecs_id]
  alb_security_groups = [module.networking.sg_alb_id]
  vpc_id              = module.networking.vpc_id
  environment_variables = [
    {
      "name" : "NEPTUNE_HOST",
      "value" : "${module.neptune.neptune_endpoint}"
    },
    {
      "name" : "NEPTUNE_PORT",
      "value" : "8182"
    },
    {
      "name" : "DYNAMODB_TABLE",
      "value" : "${module.dynamodb.table_name}"
    },
    {
      "name" : "ES_HOST",
      "value" : "https://${module.elasticsearch.endpoint}"
    },
    {
      "name" : "ANALYTICS_BUCKET",
      "value" : "${module.s3-analytics.s3_bucket_id}"
    },
    {
      "name" : "COMPUTE_BUCKET",
      "value" : "${module.s3-compute.s3_bucket_id}"
    }
  ]
  secrets = [
    {
      "name" : "DB_HOST",
      "valueFrom" : "${module.rds.rds_postgres_address_ssm_arn}"
    },
    {
      "name" : "DB_USERNAME",
      "valueFrom" : "${module.rds.rds_postgres_username_ssm_arn}"
    },
    {
      "name" : "DB_PASSWORD",
      "valueFrom" : "${module.rds.rds_postgres_password_ssm_arn}"
    }
  ]
}


####################
## Lambda Functions
####################

module "dataingestion" {
  source = "../../modules/lambda"

  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  function_name          = "dataingestion"
  vpc_subnet_ids         = flatten(["${module.networking.subnets_priv_id}"])
  lambda_role            = module.iam.dataingestion_lambda_role_arn
  runtime                = "python3.8"
  handler                = "dataingestion.handler"
  vpc_security_group_ids = [module.networking.sg_lambda_id]
  environment_variables = {
    DB_NAME               = "${local.prefix}_db_${local.suffix}"
    DB_USER               = var.db-username
    DB_PASSWORD           = var.db-password
    DB_HOST               = module.rds.db_host_address
    DB_PORT               = "5432"
    API_GW_URL            = "https://${var.api-domain-name}"
    NEPTUNE_HOST          = module.neptune.neptune_endpoint
    NEPTUNE_PORT          = "8182"
    ES_HOST               = "https://${module.elasticsearch.endpoint}"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}

module "inforeq" {
  source = "../../modules/lambda"

  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  function_name          = "inforeq"
  vpc_subnet_ids         = flatten(["${module.networking.subnets_priv_id}"])
  lambda_role            = module.iam.inforeq_lambda_role_arn
  runtime                = "python3.8"
  handler                = "inforeq.handler"
  vpc_security_group_ids = [module.networking.sg_lambda_id]
  environment_variables = {
    DB_NAME               = "${local.prefix}_db_${local.suffix}"
    DB_USER               = var.db-username
    DB_PASSWORD           = var.db-password
    DB_HOST               = module.rds.db_host_address
    DB_PORT               = "5432"
    API_GW_URL            = "https://${var.api-domain-name}"
    NEPTUNE_HOST          = module.neptune.neptune_endpoint
    NEPTUNE_PORT          = "8182"
    ES_HOST               = "https://${module.elasticsearch.endpoint}"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}

module "searchengine" {
  source = "../../modules/lambda"

  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  function_name          = "searchengine"
  vpc_subnet_ids         = flatten(["${module.networking.subnets_priv_id}"])
  lambda_role            = module.iam.searchengine_lambda_role_arn
  runtime                = "python3.8"
  handler                = "searchengine.handler"
  vpc_security_group_ids = [module.networking.sg_lambda_id]
  environment_variables = {
    DB_NAME               = "${local.prefix}_db_${local.suffix}"
    DB_USER               = var.db-username
    DB_PASSWORD           = var.db-password
    DB_HOST               = module.rds.db_host_address
    DB_PORT               = "5432"
    API_GW_URL            = "https://${var.api-domain-name}"
    NEPTUNE_HOST          = module.neptune.neptune_endpoint
    NEPTUNE_PORT          = "8182"
    ES_HOST               = "https://${module.elasticsearch.endpoint}"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}

module "notificationCenter" {
  source = "../../modules/lambda"

  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  function_name          = "notificationCenter"
  vpc_subnet_ids         = flatten(["${module.networking.subnets_priv_id}"])
  lambda_role            = module.iam.notificationCenter_lambda_role_arn
  runtime                = "python3.8"
  handler                = "notificationCenter.handler"
  vpc_security_group_ids = [module.networking.sg_lambda_id]
  environment_variables = {
    DB_NAME               = "${local.prefix}_db_${local.suffix}"
    DB_USER               = var.db-username
    DB_PASSWORD           = var.db-password
    DB_HOST               = module.rds.db_host_address
    DB_PORT               = "5432"
    API_GW_URL            = "https://${var.api-domain-name}"
    NEPTUNE_HOST          = module.neptune.neptune_endpoint
    NEPTUNE_PORT          = "8182"
    ES_HOST               = "https://${module.elasticsearch.endpoint}"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}

module "accountManagement" {
  source = "../../modules/lambda"

  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  function_name          = "accountManagement"
  vpc_subnet_ids         = flatten(["${module.networking.subnets_priv_id}"])
  lambda_role            = module.iam.accountManagement_lambda_role_arn
  runtime                = "python3.8"
  handler                = "accountManagement.handler"
  vpc_security_group_ids = [module.networking.sg_lambda_id]
  environment_variables = {
    DB_NAME               = "${local.prefix}_db_${local.suffix}"
    DB_USER               = var.db-username
    DB_PASSWORD           = var.db-password
    DB_HOST               = module.rds.db_host_address
    DB_PORT               = "5432"
    API_GW_URL            = "https://${var.api-domain-name}"
    NEPTUNE_HOST          = module.neptune.neptune_endpoint
    NEPTUNE_PORT          = "8182"
    ES_HOST               = "https://${module.elasticsearch.endpoint}"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}

module "dataManagement" {
  source = "../../modules/lambda"

  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  function_name          = "dataManagement"
  vpc_subnet_ids         = flatten(["${module.networking.subnets_priv_id}"])
  lambda_role            = module.iam.dataManagement_lambda_role_arn
  runtime                = "python3.8"
  handler                = "dataManagement.handler"
  vpc_security_group_ids = [module.networking.sg_lambda_id]
  environment_variables = {
    DB_NAME               = "${local.prefix}_db_${local.suffix}"
    DB_USER               = var.db-username
    DB_PASSWORD           = var.db-password
    DB_HOST               = module.rds.db_host_address
    DB_PORT               = "5432"
    API_GW_URL            = "https://${var.api-domain-name}"
    NEPTUNE_HOST          = module.neptune.neptune_endpoint
    NEPTUNE_PORT          = "8182"
    ES_HOST               = "https://${module.elasticsearch.endpoint}"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}

module "userProfile" {
  source = "../../modules/lambda"

  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  function_name          = "userProfile"
  vpc_subnet_ids         = flatten(["${module.networking.subnets_priv_id}"])
  lambda_role            = module.iam.userProfile_lambda_role_arn
  runtime                = "python3.8"
  handler                = "userProfile.handler"
  vpc_security_group_ids = [module.networking.sg_lambda_id]
  environment_variables = {
    DB_NAME               = "${local.prefix}_db_${local.suffix}"
    DB_USER               = var.db-username
    DB_PASSWORD           = var.db-password
    DB_HOST               = module.rds.db_host_address
    DB_PORT               = "5432"
    API_GW_URL            = "https://${var.api-domain-name}"
    NEPTUNE_HOST          = module.neptune.neptune_endpoint
    NEPTUNE_PORT          = "8182"
    ES_HOST               = "https://${module.elasticsearch.endpoint}"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}

module "orgManagement" {
  source = "../../modules/lambda"

  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  function_name          = "orgManagement"
  vpc_subnet_ids         = flatten(["${module.networking.subnets_priv_id}"])
  lambda_role            = module.iam.orgManagement_lambda_role_arn
  runtime                = "python3.8"
  handler                = "orgManagement.handler"
  vpc_security_group_ids = [module.networking.sg_lambda_id]
  environment_variables = {
    DB_NAME               = "${local.prefix}_db_${local.suffix}"
    DB_USER               = var.db-username
    DB_PASSWORD           = var.db-password
    DB_HOST               = module.rds.db_host_address
    DB_PORT               = "5432"
    API_GW_URL            = "https://${var.api-domain-name}"
    NEPTUNE_HOST          = module.neptune.neptune_endpoint
    NEPTUNE_PORT          = "8182"
    ES_HOST               = "https://${module.elasticsearch.endpoint}"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}

module "externalapi" {
  source = "../../modules/lambda"

  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  function_name          = "externalapi"
  vpc_subnet_ids         = flatten(["${module.networking.subnets_priv_id}"])
  lambda_role            = module.iam.externalapi_lambda_role_arn
  runtime                = "python3.8"
  handler                = "externalapi.handler"
  vpc_security_group_ids = [module.networking.sg_lambda_id]
  environment_variables = {
    DB_NAME               = "${local.prefix}_db_${local.suffix}"
    DB_USER               = var.db-username
    DB_PASSWORD           = var.db-password
    DB_HOST               = module.rds.db_host_address
    DB_PORT               = "5432"
    API_GW_URL            = "https://${var.api-domain-name}"
    NEPTUNE_HOST          = module.neptune.neptune_endpoint
    NEPTUNE_PORT          = "8182"
    ES_HOST               = "https://${module.elasticsearch.endpoint}"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}


####################
## IAM
####################

module "iam" {
  source      = "../../modules/iam"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  landing_bucket_name   = module.s3-landing.s3_bucket_id
  raw_bucket_name       = module.s3-raw.s3_bucket_id
  compute_bucket_name   = module.s3-compute.s3_bucket_id
  analytics_bucket_name = module.s3-analytics.s3_bucket_id
}

####################
## API Gateway
####################

module "apigateway" {
  source              = "../../modules/apigateway"
  region              = var.region
  project             = var.project
  owner               = var.owner
  environment         = var.environment
  website-domain-main = var.website-domain-main
  api-domain-name     = var.api-domain-name

  cognito-user-pool_arn         = module.cognito.cognito_user_pool_arn
  dataingestion_invoke_arn      = module.dataingestion.alias_invoke_arn
  inforeq_invoke_arn            = module.inforeq.alias_invoke_arn
  searchengine_invoke_arn       = module.searchengine.alias_invoke_arn
  notificationCenter_invoke_arn = module.notificationCenter.alias_invoke_arn
  accountManagement_invoke_arn  = module.accountManagement.alias_invoke_arn
  dataManagement_invoke_arn     = module.dataManagement.alias_invoke_arn
  orgManagement_invoke_arn      = module.orgManagement.alias_invoke_arn
  userProfile_invoke_arn        = module.userProfile.alias_invoke_arn

  dataingestion_fn_name      = module.dataingestion.function_name
  inforeq_fn_name            = module.inforeq.function_name
  searchengine_fn_name       = module.searchengine.function_name
  notificationCenter_fn_name = module.notificationCenter.function_name
  accountManagement_fn_name  = module.accountManagement.function_name
  dataManagement_fn_name     = module.dataManagement.function_name
  userProfile_fn_name        = module.userProfile.function_name
  orgManagement_fn_name      = module.orgManagement.function_name

  acm_website_cert_arn = module.acm.acm_website_cert_arn
}

####################
## CICD
####################

module "cicd-mgmnt" {
  source = "../../modules/cicd/cicd-mgmnt"

  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
}

module "ecs-deploy" {
  source          = "../../modules/cicd/ecs-deploy"
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
  codestar_bitbucket_arn     = module.cicd-mgmnt.codestar_bitbucket_arn
  approval_sns_arn           = module.cicd-mgmnt.approval_sns_arn
  ecs_codebuild_loggroup     = module.cicd-mgmnt.ecs_codebuild_loggroup
  ecs_codebuild_loggroup_arn = module.cicd-mgmnt.ecs_codebuild_loggroup_arn
}

module "lambda_s3-deploy" {
  source          = "../../modules/cicd/lambda_s3-deploy"
  region          = var.region
  project         = var.project
  owner           = var.owner
  environment     = var.environment
  repo_name       = var.repo_name
  api-domain-name = var.api-domain-name

  web_bucket_name                 = module.frontend.web_bucket_name
  cf_distribution_id              = module.frontend.cf_distribution_id
  codestar_bitbucket_arn          = module.cicd-mgmnt.codestar_bitbucket_arn
  approval_sns_arn                = module.cicd-mgmnt.approval_sns_arn
  lambda_codebuild_loggroup       = module.cicd-mgmnt.lambda_codebuild_loggroup
  frontend_codebuild_loggroup     = module.cicd-mgmnt.frontend_codebuild_loggroup
  lambda_codebuild_loggroup_arn   = module.cicd-mgmnt.lambda_codebuild_loggroup_arn
  frontend_codebuild_loggroup_arn = module.cicd-mgmnt.frontend_codebuild_loggroup_arn
  lambda_packages_bucket_name     = module.s3-lambda-packages.s3_bucket_id
}

####################
## Monitoring/Audit
####################

module "cloudtrail" {
  source      = "../../modules/cloudtrail"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  logging = {
    target_bucket = module.s3-cloudtrail-s3access-log.s3_bucket_id
  }

}

module "s3-cloudtrail-s3access-log" {
  source = "../../modules/s3/"

  bucket                  = "${local.prefix}-cloudtrail-s3access-log-${local.suffix}"
  acl                     = "log-delivery-write"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = false
  }

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

  force_destroy = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-cloudtrail-s3access-log-${local.suffix}" }
    )
  )

}

####################
## VPN
####################

module "vpn" {
  source      = "../../modules/vpn"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  enabled           = var.vpn_enabled
  cgw_onprem_ip     = var.cgw_onprem_ip
  onprem_cidr_block = var.onprem_cidr_block

  vpc_id              = module.networking.vpc_id
  route_table_pub_id  = flatten(["${module.networking.route_table_pub_id}"])
  route_table_priv_id = flatten(["${module.networking.route_table_priv_id}"])
}
