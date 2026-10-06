# Dashboard 1: service overview, golden signals

resource "aws_cloudwatch_dashboard" "overview_dashboard" {
  dashboard_name = local.names.overview
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "text", x = 0, y = 0, width = 8, height = 4
        properties = {
          markdown = <<-EOT
            # Neros Pizza – Service overview
            **On-call view:** user-facing health first, causes below.

            [Pipeline](${local.urls.pipeline}) · [Business](${local.urls.business})
          EOT
        }
      },
      {
        type = "alarm", x = 8, y = 0, width = 16, height = 4
        properties = {
          title = "Alarm status", 
          alarms = var.alarms.all_alarm_arns
        }
      },
      {
        type = "metric", x = 0, y = 4, width = 8, height = 6
        properties = {
          title   = "API 5xx rate"
          region  = local.region
          view    = "timeSeries"
          period  = 60
          metrics = [
            concat(["AWS/ApiGateway", "5xx"],   local.api_dims, [{ stat = "Sum", id = "m1", visible = false }]),
            concat(["AWS/ApiGateway", "Count"], local.api_dims, [{ stat = "Sum", id = "m2", visible = false }]),
            [{ expression = "IF(m2 > 0, 100 * m1 / m2, 0)", label = "5xx %", id = "e1" }],
          ]
          annotations = { 
            horizontal = [
              { 
                label = "Alarm", 
                value = var.thresholds.api_5xx_rate_percent 
              }
            ] 
          }
        }
      },
      {
        type = "metric", x = 8, y = 4, width = 8, height = 6
        properties = {
          title   = "Traffic"
          region  = local.region
          view    = "timeSeries"
          period  = 60
          metrics = [
            concat(["AWS/ApiGateway", "Count"], local.api_dims, [{ stat = "Sum", label = "Total Requests" }])
          ]
        }
      },
      {
        type = "metric", x = 16, y = 4, width = 8, height = 6
        properties = {
          title   = "Latency"
          region  = local.region
          view    = "timeSeries"
          period  = 60
          metrics = [
            concat(["AWS/ApiGateway", "Latency"], local.api_dims, [{ stat = "p50", label="P50", id = "p50"}]),
            concat(["AWS/ApiGateway", "Latency"], local.api_dims, [{ stat = "p90", label="P90", id = "p90"}]),
            concat(["AWS/ApiGateway", "Latency"], local.api_dims, [{ stat = "p99", label="P99", id = "p99"}])
          ]
          annotations = {
            horizontal = [
              {
                label = "Alarm",
                value = var.thresholds.api_p99_latency_ms
              }
            ]
          }
        }
      },
      {
        type = "metric", x = 0, y = 10, width = 8, height = 6
        properties = {
          title   = "ConcurrentExecutions"
          region  = local.region
          view    = "timeSeries"
          period  = 60
          metrics = [
            concat(["AWS/Lambda", "ConcurrentExecutions"], local.api_fn_dims , [{ stat = "Maximum", label="Order API", id = "m1"}]),
            concat(["AWS/Lambda", "ConcurrentExecutions"], local.wk_fn_dims, [{ stat = "Maximum", label="Order Worker", id = "m2"}]),
          ]
        }
      },
      {
        type = "metric", x = 8, y = 10, width = 8, height = 6
        properties = {
          title   = "Throttles"
          region  = local.region
          view    = "timeSeries"
          period  = 60
          metrics = [
            concat(["AWS/Lambda", "Throttles"], local.api_fn_dims , [{ stat = "Sum", label="Order API", id = "m1"}]),
            concat(["AWS/Lambda", "Throttles"], local.wk_fn_dims, [{ stat = "Sum", label="Order Worker", id = "m2"}]),
          ]
        }
      },
      {
        type = "metric", x = 16, y = 10, width = 8, height = 6
        properties = {
          title   = "Duration vs timeout"
          region  = local.region
          view    = "timeSeries"
          period  = 60
          metrics = [
            concat(["AWS/Lambda", "Duration"], local.api_fn_dims , [{ stat = "p95", label="Order API P95", id = "m1"}])
          ]
          annotations = {
            horizontal = [
              {
                label = "Timeout 80%"
                value = var.workload.api_function_timeout_ms * var.thresholds.duration_timeout_ratio
              },
              {
                label = "Timeout 100%"
                value = var.workload.api_function_timeout_ms
              }
            ]
          }
        }
      },
      {
        type = "metric", x = 0, y = 16, width = 8, height = 6
        properties = {
          title   = "Canary"
          region  = local.region
          view    = "timeSeries"
          period  = 300
          metrics = [
            ["CloudWatchSynthetics", "SuccessPercent", "CanaryName", var.synthetics.canary_name , { stat = "Average", label="SuccessPercent", id = "m1"}]
          ]
          yAxis = { left = { min = 0, max = 100 } }
        }
      },
      {
        type = "log", x = 8, y = 16, width = 16, height = 6
        properties = {
          title  = "Top errors (last range)"
          region = local.region
          view   = "table"
          query  = "SOURCE '${var.logging.api_log_group_name}' | filter level = \"ERROR\" | stats count(*) as errors by reason, route | sort errors desc | limit 10"
        }
      }
    ]
  })
}