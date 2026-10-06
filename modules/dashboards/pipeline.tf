# Dashboard 2: async pipeline (queue, DLQ, worker)
resource "aws_cloudwatch_dashboard" "pipeline" {
  dashboard_name = local.names.pipeline

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "text", x = 0, y = 0, width = 24, height = 2
        properties = {
          markdown = <<-EOT
            # Async pipeline - ${var.name_prefix}
            Queue depth and age show backlog; DLQ > 0 means messages failed 3 times. 
            
            [Overview](${local.urls.overview}) · [Business](${local.urls.business})
          EOT
        }
      },
      {
        type = "metric", x = 0, y = 2, width = 8, height = 6
        properties = {
          title  = "Main queue depth"
          region = local.region
          view   = "timeSeries"
          period = 60
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.workload.queue_name, { stat = "Maximum", label = "Waiting" }],
            ["AWS/SQS", "ApproximateNumberOfMessagesNotVisible", "QueueName", var.workload.queue_name, { stat = "Maximum", label = "In flight" }],
          ]
        }
      },
      {
        type = "metric", x = 8, y = 2, width = 8, height = 6
        properties = {
          title  = "Oldest message age (s)"
          region = local.region
          view   = "timeSeries"
          period = 60
          metrics = [
            ["AWS/SQS", "ApproximateAgeOfOldestMessage", "QueueName", var.workload.queue_name, { stat = "Maximum", label = "Age" }],
          ]
          annotations = {
            horizontal = [{ label = "Alarm", value = var.thresholds.queue_age_seconds }]
          }
        }
      },
      {
        type = "metric", x = 16, y = 2, width = 8, height = 6
        properties = {
          title     = "DLQ messages"
          region    = local.region
          view      = "singleValue"
          sparkline = true
          period    = 60
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.workload.dlq_name, { stat = "Maximum", label = "In DLQ" }],
          ]
        }
      },
      {
        type = "metric", x = 0, y = 8, width = 12, height = 6
        properties = {
          title  = "Messages in vs out"
          region = local.region
          view   = "timeSeries"
          period = 60
          metrics = [
            ["AWS/SQS", "NumberOfMessagesSent", "QueueName", var.workload.queue_name, { stat = "Sum", label = "Sent (in)" }],
            ["AWS/SQS", "NumberOfMessagesDeleted", "QueueName", var.workload.queue_name, { stat = "Sum", label = "Deleted (processed)" }],
          ]
        }
      },
      {
        type = "metric", x = 12, y = 8, width = 12, height = 6
        properties = {
          title  = "Worker invocations vs errors"
          region = local.region
          view   = "timeSeries"
          period = 60
          metrics = [
            concat(["AWS/Lambda", "Invocations"], local.wk_fn_dims, [{ stat = "Sum", label = "Invocations" }]),
            concat(["AWS/Lambda", "Errors"], local.wk_fn_dims, [{ stat = "Sum", label = "Errors" }]),
          ]
        }
      },
      {
        type = "log", x = 0, y = 14, width = 24, height = 6
        properties = {
          title  = "Latest failed messages"
          region = local.region
          view   = "table"
          query  = "SOURCE '${var.logging.worker_log_group_name}' | filter event = \"order_failed\" | fields @timestamp, messageId, reason, receiveCount | sort @timestamp desc | limit 20"
        }
      },
    ]
  })
}