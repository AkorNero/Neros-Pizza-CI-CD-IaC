# Dashboard 3: OrdersPlaced, anomaly band, OrderValue
locals {
  emf_dims = ["Service", var.emf_service_name]
}

resource "aws_cloudwatch_dashboard" "business" {
  dashboard_name = local.names.business

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "text", x = 0, y = 0, width = 24, height = 2
        properties = {
          markdown = <<-EOT
            # Business - ${var.name_prefix}
            Orders and revenue from EMF. The grey band is what the "orders dropped" alarm expects. 
            
            [Overview](${local.urls.overview}) · [Pipeline](${local.urls.pipeline})
          EOT
        }
      },
      {
        type = "metric", x = 0, y = 2, width = 16, height = 6
        properties = {
          title  = "Orders placed vs expected band"
          region = local.region
          view   = "timeSeries"
          period = 300
          metrics = [
            concat([var.emf_namespace, "OrdersPlaced"], local.emf_dims, [{ stat = "Sum", id = "m1", label = "Orders" }]),
            [{ expression = "ANOMALY_DETECTION_BAND(m1, ${var.thresholds.anomaly_band_width})", id = "ad1", label = "Expected range" }],
          ]
        }
      },
      {
        type = "metric", x = 16, y = 2, width = 8, height = 6
        properties = {
          title                = "Orders (selected range)"
          region               = local.region
          view                 = "singleValue"
          stat                 = "Sum"
          period               = 300
          setPeriodToTimeRange = true
          metrics = [
            concat([var.emf_namespace, "OrdersPlaced"], local.emf_dims, [{ label = "Orders" }]),
          ]
        }
      },
      {
        type = "metric", x = 0, y = 8, width = 24, height = 6
        properties = {
          title  = "Revenue per hour and average order value"
          region = local.region
          view   = "timeSeries"
          period = 3600
          metrics = [
            concat([var.emf_namespace, "OrderValue"], local.emf_dims, [{ stat = "Sum", id = "rev", label = "Revenue / hour" }]),
            concat([var.emf_namespace, "OrdersPlaced"], local.emf_dims, [{ stat = "Sum", id = "cnt", visible = false }]),
            [{ expression = "IF(cnt > 0, rev / cnt, 0)", id = "aov", label = "Avg order value", yAxis = "right" }],
          ]
        }
      },
    ]
  })
}