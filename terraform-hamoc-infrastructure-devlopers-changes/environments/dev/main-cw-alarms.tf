####################
## SNS Alerts
####################

module "sns-alerts" {
  source      = "../../modules/sns"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = "Alerts"
}

####################
## ECS Alarms
####################

module "cw-alarm-ALB_Healthy_host_count" {

  source      = "../../modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "ECS_App_ALB_Healthy_host_count"
  alarm_description         = "Healthy host count for ECS Application less than desired count 1"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1"
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

  source      = "../../modules/cloudwatch_alarms"
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

  source      = "../../modules/cloudwatch_alarms"
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

####################
## RDS Alarms
####################

module "cw-alarm-RDS-High_CPU" {

  source      = "../../modules/cloudwatch_alarms"
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
    DBInstanceIdentifier = module.rds.db_host_identifier
  }
}

module "cw-alarm-RDS-Low_Storage_Space" {

  source      = "../../modules/cloudwatch_alarms"
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
    DBInstanceIdentifier = module.rds.db_host_identifier
  }
}

####################
## Bastion Alarms
####################

module "cw-alarm-Bastion-Host-High_CPU" {

  source      = "../../modules/cloudwatch_alarms"
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
    InstanceId = module.networking.bastion_host_instance_id
  }
}

module "cw-alarm-Bastion-Host-Status_Check_Fail" {

  source      = "../../modules/cloudwatch_alarms"
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
    InstanceId = module.networking.bastion_host_instance_id
  }
}

####################
## ES Alarms
####################

module "cw-alarm-ES-Cluster_Status_Red" {
  source      = "../../modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "ElasticSearch-Cluster_Status_Red"
  alarm_description         = "ElasticSearch Cluster Status Red"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "ClusterStatus.red"
  namespace                 = "AWS/ES"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "breaching"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    DomainName = module.elasticsearch.domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

module "cw-alarm-ES-Cluster_Status_Yellow" {
  source      = "../../modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "ElasticSearch-Cluster_Status_Yellow"
  alarm_description         = "ElasticSearch Cluster Status Yellow"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "ClusterStatus.yellow"
  namespace                 = "AWS/ES"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "breaching"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    DomainName = module.elasticsearch.domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }
}


module "cw-alarm-ES-High_CPU" {
  source      = "../../modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "ElasticSearch-Cluster_High_CPU"
  alarm_description         = "ElasticSearch Cluster High CPU"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "3"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ES"
  period                    = "600"
  statistic                 = "Average"
  threshold                 = "60"
  treat_missing_data        = "breaching"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    DomainName = module.elasticsearch.domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

module "cw-alarm-ES-Low_Storage" {
  source      = "../../modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "ElasticSearch-Cluster_Low_Storage"
  alarm_description         = "ElasticSearch Cluster Low Storage"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "FreeStorageSpace"
  namespace                 = "AWS/ES"
  period                    = "60"
  statistic                 = "Minimum"
  unit                      = "Megabytes"
  threshold                 = "3000" //3GB
  treat_missing_data        = "breaching"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    DomainName = module.elasticsearch.domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

module "cw-alarm-ES-cluster_index_writes_blocked" {
  source      = "../../modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "ElasticSearch-Cluster_cluster_index_writes_blocked"
  alarm_description         = "ElasticSearch Cluster cluster index writes blocked"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "ClusterIndexWritesBlocked"
  namespace                 = "AWS/ES"
  period                    = "300"
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "breaching"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    DomainName = module.elasticsearch.domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

module "cw-alarm-ES-automated_snapshot_failure" {
  source      = "../../modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "ElasticSearch-Cluster_automated_snapshot_failure"
  alarm_description         = "ElasticSearch Cluster automated snapshot failure"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "AutomatedSnapshotFailure"
  namespace                 = "AWS/ES"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "breaching"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    DomainName = module.elasticsearch.domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

####################
## Neptune Alarms
####################

module "cw-alarm-Neptune-High_CPU" {

  source      = "../../modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name                = "Neptune-High_CPU"
  alarm_description         = "Neptune CPU above 60"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/Neptune"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "60.0"
  treat_missing_data        = "breaching"
  alarm_actions             = [module.sns-alerts.sns_topic_arn]
  ok_actions                = [module.sns-alerts.sns_topic_arn]
  insufficient_data_actions = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    DBClusterIdentifier = module.neptune.neptune_identifier
  }
}


####################
## Dynamodb Alarms
####################

module "cw-alarm-Dynamodb-System_Errors" {

  source      = "../../modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  alarm_name          = "Dynamodb-System_Errors"
  alarm_description   = "Dynamodb System Errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "SystemErrors"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_actions       = [module.sns-alerts.sns_topic_arn]
  ok_actions          = [module.sns-alerts.sns_topic_arn]

  dimensions = {
    TableName = module.dynamodb.table_name
  }
}

####################
## VPN Alarms
####################

module "cw-alarm-VPN-Tunnel_Down" {

  source      = "../../modules/cloudwatch_alarms"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment

  create_metric_alarm       = false
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
    VpnId = module.vpn.sts_vpn_id
  }
}

####################
## CIS Alarms
####################

module "cis-alarms" {
  source      = "../../modules/cis-alarms"
  project     = var.project
  owner       = var.owner
  environment = var.environment

  log_group_name = module.cloudtrail.cloudwatch_log_group_name
  alarm_actions  = [module.sns-cis-alarms.sns_topic_arn]
}

module "sns-cis-alarms" {
  source      = "../../modules/sns"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = "CIS-Alarms"
}

####################
## AWS Config
####################

module "sns-config-alerts" {
  source      = "../../modules/sns"
  region      = var.region
  project     = var.project
  owner       = var.owner
  environment = var.environment
  name        = "config-alerts"

  sns_topic_policy_json = data.template_file.aws_config_sns_policy.rendered
}

module "s3-awsconfig" {
  source = "../../modules/s3/"

  bucket                  = "${local.prefix}-awsconfig-${local.suffix}"
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
    tomap({ "Name" = "${local.prefix}-awsconfig-${local.suffix}" }
    )
  )

}

module "aws_config" {
  source               = "../../modules/aws_config"
  project              = var.project
  owner                = var.owner
  environment          = var.environment

  config_logs_bucket   = module.s3-awsconfig.s3_bucket_id
  config_sns_topic_arn = module.sns-config-alerts.sns_topic_arn
}