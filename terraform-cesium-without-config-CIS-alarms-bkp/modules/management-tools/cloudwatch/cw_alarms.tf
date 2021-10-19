##ECS Fargate ALB healthy host count alarm
resource "aws_cloudwatch_metric_alarm" "ecs_alb_healthy_host_count" {
  alarm_name                = "${local.prefix}-${local.suffix}-ecs_app_alb_healthy_host_count"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = local.suffix == "prod" ? 2 : 1
  treat_missing_data        = "breaching"
  alarm_actions             = [aws_sns_topic.alert_sns.arn]
  ok_actions                = [aws_sns_topic.alert_sns.arn]
  alarm_description         = "Healthy host count for ecs_fargate_app less than desired count ${local.suffix == "prod" ? 2 : 1}"
  insufficient_data_actions = [aws_sns_topic.alert_sns.arn]

  dimensions = {
    LoadBalancer = var.ecs_alb_arn_suffix
    TargetGroup  = var.ecs_alb_tg_arn_suffix
  }
}

##ECS Service cpu and memory alarm
resource "aws_cloudwatch_metric_alarm" "ecs_svc_cpu" {
  alarm_name                = "${local.prefix}-${local.suffix}-ecs_app_high_cpu"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "60.0"
  treat_missing_data        = "breaching"
  alarm_description         = "${local.prefix}-${local.suffix} ECS_App CPU above 60"
  alarm_actions             = [aws_sns_topic.alert_sns.arn]
  ok_actions                = [aws_sns_topic.alert_sns.arn]
  insufficient_data_actions = [aws_sns_topic.alert_sns.arn]

  dimensions = {
    ServiceName = var.ecs_servicename
    ClusterName = var.ecs_clustername
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_svc_mem_60" {
  alarm_name                = "${local.prefix}-${local.suffix}-ecs_app_high_memory"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "60.0"
  treat_missing_data        = "breaching"
  alarm_description         = "${local.prefix}-${local.suffix} ECS_App memory above 60"
  alarm_actions             = [aws_sns_topic.alert_sns.arn]
  ok_actions                = [aws_sns_topic.alert_sns.arn]
  insufficient_data_actions = [aws_sns_topic.alert_sns.arn]

  dimensions = {
    ServiceName = var.ecs_servicename
    ClusterName = var.ecs_clustername
  }
}

## Prod RDS Alarms
resource "aws_cloudwatch_metric_alarm" "RDS-CPU" {
  alarm_name                = "${local.prefix}-${local.suffix}-RDS-High_CPU"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "60.0"
  treat_missing_data        = "breaching"
  alarm_description         = "RDS CPU above 60 for ${local.prefix}-${local.suffix}"
  alarm_actions             = [aws_sns_topic.alert_sns.arn]
  ok_actions                = [aws_sns_topic.alert_sns.arn]
  insufficient_data_actions = [aws_sns_topic.alert_sns.arn]

  dimensions = {
    DBInstanceIdentifier = var.db-host-identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "RDS-Storage" {
  alarm_name                = "${local.prefix}-${local.suffix}-RDS Low Storage Space"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "FreeStorageSpace"
  namespace                 = "AWS/RDS"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "20000000000.0"
  treat_missing_data        = "breaching"
  alarm_description         = "RDS Low Storage Space < 20GB for ${local.prefix}-${local.suffix}"
  alarm_actions             = [aws_sns_topic.alert_sns.arn]
  ok_actions                = [aws_sns_topic.alert_sns.arn]
  insufficient_data_actions = [aws_sns_topic.alert_sns.arn]

  dimensions = {
    DBInstanceIdentifier = var.db-host-identifier
  }
}

##EC2 ETL High CPU
resource "aws_cloudwatch_metric_alarm" "ec2-etl-high-cpu" {
  alarm_name                = "${local.prefix}-${local.suffix}-EC2-ETL-High_CPU"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "60"
  treat_missing_data        = "breaching"
  alarm_description         = "EC2 ETL CPU above 60 for ${local.prefix}-${local.suffix}"
  alarm_actions             = [aws_sns_topic.alert_sns.arn]
  ok_actions                = [aws_sns_topic.alert_sns.arn]
  insufficient_data_actions = [aws_sns_topic.alert_sns.arn]

  dimensions = {
    InstanceId = var.ec2-etl-instance-id
  }
}

#EC2 ETL Status check
resource "aws_cloudwatch_metric_alarm" "ec2-etl-status-checkfail" {
  alarm_name                = "${local.prefix}-${local.suffix}-EC2-ETL-Status-Check-Fail"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1.0"
  treat_missing_data        = "breaching"
  alarm_description         = "EC2 ETL Status Check Fail for ${local.prefix}-${local.suffix}"
  alarm_actions             = [aws_sns_topic.alert_sns.arn]
  ok_actions                = [aws_sns_topic.alert_sns.arn]
  insufficient_data_actions = [aws_sns_topic.alert_sns.arn]

  dimensions = {
    InstanceId = var.ec2-etl-instance-id
  }
}

##Bastion host High CPU
resource "aws_cloudwatch_metric_alarm" "bastion-host-high-cpu" {
  alarm_name                = "${local.prefix}-${local.suffix}-Bastion-Host-High_CPU"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "60"
  treat_missing_data        = "breaching"
  alarm_description         = "Bastion host CPU above 60 for ${local.prefix}-${local.suffix}"
  alarm_actions             = [aws_sns_topic.alert_sns.arn]
  ok_actions                = [aws_sns_topic.alert_sns.arn]
  insufficient_data_actions = [aws_sns_topic.alert_sns.arn]

  dimensions = {
    InstanceId = var.bastion-host-instance-id
  }
}

#Bastion host Status check
resource "aws_cloudwatch_metric_alarm" "bastion-host-status-checkfail" {
  alarm_name                = "${local.prefix}-${local.suffix}-Bastion-Host-Status-Check-Fail"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1.0"
  treat_missing_data        = "breaching"
  alarm_description         = "Bastion host Status Check Fail for ${local.prefix}-${local.suffix}"
  alarm_actions             = [aws_sns_topic.alert_sns.arn]
  ok_actions                = [aws_sns_topic.alert_sns.arn]
  insufficient_data_actions = [aws_sns_topic.alert_sns.arn]

  dimensions = {
    InstanceId = var.bastion-host-instance-id
  }
}

#VPN State alarm
resource "aws_cloudwatch_metric_alarm" "vpn-tunnel-down" {
  count                     = local.suffix == "dev" ? 0 : 1
  alarm_name                = "${local.prefix}-${local.suffix}-VPN-Tunnel-Down"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TunnelState"
  namespace                 = "AWS/VPN"
  period                    = "300"
  statistic                 = "Maximum"
  threshold                 = "0"
  treat_missing_data        = "breaching"
  alarm_description         = "Site to Site VPN Tunnel Down for ${local.prefix}-${local.suffix}"
  alarm_actions             = [aws_sns_topic.alert_sns.arn]
  ok_actions                = [aws_sns_topic.alert_sns.arn]
  insufficient_data_actions = [aws_sns_topic.alert_sns.arn]

  dimensions = {
    VpnId = var.sts-vpn-id
  }
}

#RDS Events
resource "aws_db_event_subscription" "default" {
  name      = "${local.prefix}-rds-event-sub-${local.suffix}"
  sns_topic = aws_sns_topic.alert_sns.arn
}