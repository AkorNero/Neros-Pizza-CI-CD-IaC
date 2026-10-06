resource "aws_cloudwatch_metric_alarm" "static" {
  for_each = local.static_alarms

  alarm_name          = "${var.name_prefix}-${each.key}-${each.value.severity}"
  alarm_description   = each.value.description
  namespace           = each.value.namespace
  metric_name         = each.value.metric_name
  dimensions          = each.value.dimensions
  statistic           = each.value.statistic
  period              = each.value.period
  evaluation_periods  = each.value.evaluation_periods
  datapoints_to_alarm = each.value.datapoints_to_alarm
  threshold           = each.value.threshold
  comparison_operator = each.value.comparison_operator
  treat_missing_data  = each.value.treat_missing_data
  alarm_actions       = each.value.severity != "page" ? [local.topics[each.value.severity]] : null
  ok_actions          = each.value.severity != "page" ? [local.topics[each.value.severity]] : null
}