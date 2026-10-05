resource "aws_cloudwatch_metric_alarm" "percentile" {
  for_each = local.percentile_alarm

  alarm_name          = "${var.name_prefix}-${each.key}-${each.value.severity}"
  alarm_description   = each.value.description
  namespace           = each.value.namespace
  metric_name         = each.value.metric_name
  dimensions          = each.value.dimensions
  extended_statistic  = each.value.extended_statistic
  evaluate_low_sample_count_percentiles = each.value.evaluate_low_sample_count_percentiles
  period              = each.value.period
  evaluation_periods  = each.value.evaluation_periods
  datapoints_to_alarm = each.value.datapoints_to_alarm
  threshold           = each.value.threshold
  comparison_operator = each.value.comparison_operator
  treat_missing_data  = each.value.treat_missing_data
  alarm_actions       = [local.topics[each.value.severity]]
  ok_actions          = [local.topics[each.value.severity]]
}