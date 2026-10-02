resource "aws_cloudwatch_log_anomaly_detector" "access_log_anomaly_detection" {
  log_group_arn_list = [aws_cloudwatch_log_group.order_api_access_log_group.arn]
  detector_name = "${var.name_prefix}-order-api-access-anomalies"
  evaluation_frequency = "TEN_MIN"
  enabled = true
}