resource "aws_cloudwatch_metric_alarm" "math" {
  for_each = local.math_alarms

  alarm_name          = "${var.name_prefix}-${each.key}-${each.value.severity}"
  alarm_description   = each.value.description

  metric_query {
    id          = "result"
    expression  = each.value.expression
    label = each.key
    return_data = true
  }

  dynamic "metric_query" {
    for_each = each.value.metrics
    content {
      id = metric_query.key
      metric {
        namespace   = metric_query.value.namespace
        metric_name = metric_query.value.name
        dimensions  = metric_query.value.dims
        stat        = metric_query.value.stat
        period      = each.value.period
      }
    }
  }

  evaluation_periods = each.value.evaluation_periods
  datapoints_to_alarm = each.value.datapoints_to_alarm
  threshold = each.value.threshold
  comparison_operator = each.value.comparison_operator
  treat_missing_data = each.value.treat_missing_data
  alarm_actions       = each.value.severity != "page" ? [local.topics[each.value.severity]] : null
  ok_actions          = each.value.severity != "page" ? [local.topics[each.value.severity]] : null
}