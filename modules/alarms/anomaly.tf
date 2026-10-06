resource "aws_cloudwatch_metric_alarm" "anomaly_order_placed" {
  alarm_name        = "${var.name_prefix}-anomaly-order-placed-warning"
  alarm_description = "Orders placed (EMF OrdersPlaced) below the expected anomaly band (${var.thresholds.anomaly_band_width} std dev) for 15 min. Traffic may be dropping or orders failing silently. Check the API 5xx rate, the canary, recent deploys and app error logs."

  metric_query {
    id = "m1"
    metric {
      namespace   = var.emf_namespace
      metric_name = "OrdersPlaced"
      stat        = "Sum"
      period      = 300
    }
    return_data = true
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    return_data = true
  }

  comparison_operator = "LessThanLowerThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  threshold_metric_id = "ad1"
  treat_missing_data  = "breaching"
  alarm_actions       = [local.topics["warning"]]
  ok_actions          = [local.topics["warning"]]
}