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
  engine_version          = "12.7"
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

# module "s3-lambda-packages" {
#   source = "../../modules/s3/"

#   bucket                  = "${local.prefix}-lambda-packages-${local.suffix}"
#   acl                     = "private"
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true

#   versioning = {
#     enabled = false
#   }

#   server_side_encryption_configuration = {
#     rule = {
#       apply_server_side_encryption_by_default = {
#         kms_master_key_id = data.aws_kms_alias.s3.arn
#         sse_algorithm     = "aws:kms"
#       }
#     }
#   }

#   force_destroy = true

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}-lambda-packages-${local.suffix}" }
#     )
#   )

# }

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
      "value" : "${module.elasticsearch.endpoint}"
    },
    {
      "name" : "ES_PORT",
      "value" : "443"
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

module "ecr-dataingestion" {
  source = "../../modules/ecr"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = lower("dataingestion")
}

module "dataingestion" {
  source = "../../modules/lambda"

  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  function_name          = "dataingestion"
  vpc_subnet_ids         = flatten(["${module.networking.subnets_priv_id}"])
  vpc_security_group_ids = [module.networking.sg_lambda_id]
  lambda_role            = module.iam.dataingestion_lambda_role_arn
  package_type           = "Image"
  image_uri              = "${data.aws_ecr_repository.hello-world.repository_url}:latest"
  environment_variables = {
    DB_NAME               = "${local.prefix}_db_${local.suffix}"
    DB_USER               = var.db-username
    DB_PASSWORD           = var.db-password
    DB_HOST               = module.rds.db_host_address
    DB_PORT               = "5432"
    API_GW_URL            = "https://${var.api-domain-name}"
    NEPTUNE_HOST          = module.neptune.neptune_endpoint
    NEPTUNE_PORT          = "8182"
    ES_HOST               = "${module.elasticsearch.endpoint}"
    ES_PORT               = "443"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}

module "ecr-inforeq" {
  source = "../../modules/ecr"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = lower("inforeq")
}

module "inforeq" {
  source = "../../modules/lambda"

  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  function_name          = "inforeq"
  vpc_subnet_ids         = flatten(["${module.networking.subnets_priv_id}"])
  vpc_security_group_ids = [module.networking.sg_lambda_id]
  lambda_role            = module.iam.inforeq_lambda_role_arn
  package_type           = "Image"
  image_uri              = "${data.aws_ecr_repository.hello-world.repository_url}:latest"

  environment_variables = {
    DB_NAME               = "${local.prefix}_db_${local.suffix}"
    DB_USER               = var.db-username
    DB_PASSWORD           = var.db-password
    DB_HOST               = module.rds.db_host_address
    DB_PORT               = "5432"
    API_GW_URL            = "https://${var.api-domain-name}"
    NEPTUNE_HOST          = module.neptune.neptune_endpoint
    NEPTUNE_PORT          = "8182"
    ES_HOST               = "${module.elasticsearch.endpoint}"
    ES_PORT               = "443"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}

module "ecr-searchengine" {
  source = "../../modules/ecr"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = lower("searchengine")
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
  package_type           = "Image"
  image_uri              = "${data.aws_ecr_repository.hello-world.repository_url}:latest"
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
    ES_HOST               = "${module.elasticsearch.endpoint}"
    ES_PORT               = "443"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}

module "ecr-externalapi" {
  source = "../../modules/ecr"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = lower("externalapi")
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
  package_type           = "Image"
  image_uri              = "${data.aws_ecr_repository.hello-world.repository_url}:latest"
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
    ES_HOST               = "${module.elasticsearch.endpoint}"
    ES_PORT               = "443"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}

module "ecr-accountManagement" {
  source = "../../modules/ecr"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = lower("accountManagement")
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
  package_type           = "Image"
  image_uri              = "${data.aws_ecr_repository.hello-world.repository_url}:latest"
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
    ES_HOST               = "${module.elasticsearch.endpoint}"
    ES_PORT               = "443"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}

module "ecr-dataManagement" {
  source = "../../modules/ecr"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = lower("dataManagement")
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
  package_type           = "Image"
  image_uri              = "${data.aws_ecr_repository.hello-world.repository_url}:latest"
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
    ES_HOST               = "${module.elasticsearch.endpoint}"
    ES_PORT               = "443"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}

module "ecr-userProfile" {
  source = "../../modules/ecr"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = lower("userProfile")
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
  package_type           = "Image"
  image_uri              = "${data.aws_ecr_repository.hello-world.repository_url}:latest"
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
    ES_HOST               = "${module.elasticsearch.endpoint}"
    ES_PORT               = "443"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}

module "ecr-uploadtos3" {
  source = "../../modules/ecr"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = lower("uploadtos3")
}

module "uploadtos3" {
  source = "../../modules/lambda"

  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  function_name          = "uploadtos3"
  vpc_subnet_ids         = flatten(["${module.networking.subnets_priv_id}"])
  lambda_role            = module.iam.uploadtos3_lambda_role_arn
  package_type           = "Image"
  image_uri              = "${data.aws_ecr_repository.hello-world.repository_url}:latest"
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
    ES_HOST               = "${module.elasticsearch.endpoint}"
    ES_PORT               = "443"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}


#Deleting externalapi lamnda
/*

module "ecr-externalapi" {
  source = "../../modules/ecr"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = lower("externalapi")
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
  package_type           = "Image"
  image_uri              = "${data.aws_ecr_repository.hello-world.repository_url}:latest"
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
    ES_HOST               = "${module.elasticsearch.endpoint}"
    ES_PORT               = "443"
    DYNAMODB_TABLE        = "${module.dynamodb.table_name}"
    LANDING_BUCKET_NAME   = module.s3-landing.s3_bucket_id
    RAW_BUCKET_NAME       = module.s3-raw.s3_bucket_id
    COMPUTE_BUCKET_NAME   = module.s3-compute.s3_bucket_id
    ANALYTICS_BUCKET_NAME = module.s3-analytics.s3_bucket_id
  }
}
*/

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

  ecs_codebuild_loggroup_arn             = module.cw-loggroup-ecs_codebuild.cw_log_group_arn
  ecs_pipeline_artifacts_id              = module.s3-ecs-pipeline-artifacts.s3_bucket_id
  #lambda_packages_bucket_name           = module.s3-lambda-packages.s3_bucket_id
  web_bucket_name                        = module.frontend.web_bucket_name
  frontend_backend_pipeline_artifacts_id = module.s3-frontend_backend-pipeline-artifacts.s3_bucket_id
  lambda_codebuild_loggroup_arn          = module.cw-loggroup-lambda_codebuild.cw_log_group_arn
  frontend_codebuild_loggroup_arn        = module.cw-loggroup-frontend_codebuild.cw_log_group_arn
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
  externalapi_invoke_arn = module.externalapi.alias_invoke_arn
  accountManagement_invoke_arn  = module.accountManagement.alias_invoke_arn
  dataManagement_invoke_arn     = module.dataManagement.alias_invoke_arn
  uploadtos3_invoke_arn      = module.uploadtos3.alias_invoke_arn
  userProfile_invoke_arn        = module.userProfile.alias_invoke_arn

  dataingestion_fn_name      = module.dataingestion.function_name
  inforeq_fn_name            = module.inforeq.function_name
  searchengine_fn_name       = module.searchengine.function_name
  externalapi_fn_name = module.externalapi.function_name
  accountManagement_fn_name  = module.accountManagement.function_name
  dataManagement_fn_name     = module.dataManagement.function_name
  userProfile_fn_name        = module.userProfile.function_name
  uploadtos3_fn_name      = module.uploadtos3.function_name

  acm_website_cert_arn = module.acm.acm_website_cert_arn
}

####################
## CICD
####################

##Codestar Connection

module "codestarconnection" {
  source      = "../../modules/codestarconnection"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name          = "bitbucket"
  provider_type = "Bitbucket"
}

##SNS

module "sns-deploy-approval" {
  source      = "../../modules/sns"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = "deploy-approval"
}

module "sns-codepipeline-updates" {
  source      = "../../modules/sns"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = "codepipeline-updates"

  sns_topic_policy_json = data.template_file.codepipeline-updates_sns_policy.rendered
}

##CW Rule for CICD Notifications

module "cw-event-rule-pipelineupdates" {
  source      = "../../modules/cloudwatch_event"
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
  source      = "../../modules/cw-log-group"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name              = "ecs-codebuild"
  retention_in_days = "60"
}

module "s3-ecs-pipeline-artifacts" {
  source = "../../modules/s3/"

  bucket                  = "${local.prefix}-ecs-pipeline-artifacts-${local.suffix}"
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  force_destroy           = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ecs-pipeline-artifacts-${local.suffix}" }
    )
  )
}

## ECS Codebuild

module "ecs-fargate-codebuild" {
  source      = "../../modules/codebuild"
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
    vpc_id             = module.networking.vpc_id
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
      value = module.rds.db_host_address
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_PORT"
      value = "5432"
      type  = "PLAINTEXT"
    },
    {
      name  = "ES_HOST"
      value = "${module.elasticsearch.endpoint}"
      type  = "PLAINTEXT"
    },
    {
      name  = "ES_PORT"
      value = "443"
      type  = "PLAINTEXT"
    }
  ]
}

##ECS Codepipeline

module "ecs-pipeline" {
  source      = "../../modules/codepipeline"
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

###Lambda/Frontend CICD 

module "cw-loggroup-lambda_codebuild" {
  source      = "../../modules/cw-log-group"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name              = "lambda_codebuild"
  retention_in_days = "60"
}

module "cw-loggroup-frontend_codebuild" {
  source      = "../../modules/cw-log-group"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name              = "frontend_codebuild"
  retention_in_days = "60"
}

module "s3-frontend_backend-pipeline-artifacts" {
  source = "../../modules/s3/"

  bucket                  = "${local.prefix}-frontend-backend-pipeline-artifacts-${local.suffix}"
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  force_destroy           = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-frontend-backend-pipeline-artifacts-${local.suffix}" }
    )
  )
}

## Lambda Codebuild

module "lambda-codebuild" {
  source      = "../../modules/codebuild"
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
    vpc_id             = module.networking.vpc_id
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
      value = module.rds.db_host_address
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_PORT"
      value = "5432"
      type  = "PLAINTEXT"
    },
    {
      name  = "ES_HOST"
      value = "${module.elasticsearch.endpoint}"
      type  = "PLAINTEXT"
    },
    {
      name  = "ES_PORT"
      value = "443"
      type  = "PLAINTEXT"
    }
  ]
}

## Frontent Codebuild

module "frontend-codebuild" {
  source      = "../../modules/codebuild"
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
    vpc_id             = module.networking.vpc_id
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
      value = module.frontend.web_bucket_name
      type  = "PLAINTEXT"
    },
    {
      name  = "CLOUDFRONT_DISTRIBUTION_ID"
      value = module.frontend.cf_distribution_id
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
      value = module.rds.db_host_address
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_PORT"
      value = "5432"
      type  = "PLAINTEXT"
    },
    {
      name  = "ES_HOST"
      value = "${module.elasticsearch.endpoint}"
      type  = "PLAINTEXT"
    },
    {
      name  = "ES_PORT"
      value = "443"
      type  = "PLAINTEXT"
    }
  ]
}

##Frontend/Backend Codepipeline

module "frontend-backend-pipeline" {
  source      = "../../modules/codepipeline"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  name     = "frontend-backend-pipeline"
  role_arn = module.iam.frontend_backend_pipeline_role_arn

  artifact_store = {
    location = module.s3-frontend_backend-pipeline-artifacts.s3_bucket_id
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
