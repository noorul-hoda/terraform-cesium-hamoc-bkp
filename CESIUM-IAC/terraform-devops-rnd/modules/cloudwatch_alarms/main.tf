resource "aws_cloudwatch_metric_alarm" "this" {
  count                     = var.create_metric_alarm ? 1 : 0
  
  alarm_name                = "${local.prefix}-${local.suffix}-${var.alarm_name}"
  alarm_description         = "${local.prefix}-${local.suffix}-${var.alarm_description}"
  actions_enabled           = var.actions_enabled
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  comparison_operator       = var.comparison_operator
  evaluation_periods        = var.evaluation_periods
  threshold                 = var.threshold
  unit                      = var.unit
  datapoints_to_alarm       = var.datapoints_to_alarm
  treat_missing_data        = var.treat_missing_data
  metric_name               = var.metric_name
  namespace                 = var.namespace
  period                    = var.period
  statistic                 = var.statistic

  dimensions = var.dimensions

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${local.suffix}-${var.alarm_name}" }
    )
  )

}
