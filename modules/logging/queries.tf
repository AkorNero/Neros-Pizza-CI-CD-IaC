# resource "aws_cloudwatch_query_definition" "top_errors_query" {
#   name = "${var.name_prefix}/top-error"
#   log_group_names = [aws_cloudwatch_log_group.order_api_log_group.name]
#   query_string = <<-EOT
#   fields @timestamp, message, route
#   | filter level = "ERROR"
#   | stats count(*) as errors by route
#   | sort errors desc
#   EOT
# }

# resource "aws_cloudwatch_query_definition" "access_group_latency_query" {
#   name = "${var.name_prefix}/access-group-latency"
#   log_group_names = [aws_cloudwatch_log_group.order_api_access_log_group.name]
#   query_string = <<-EOT
#   fields @timestamp, routeKey, status, responseLatency, integrationLatency
#   | sort responseLatency desc
#   | limit 20
#   EOT
# }

# resource "aws_cloudwatch_query_definition" "access_group_latency_percentile_query" {
#   name = "${var.name_prefix}/access-group-latency"
#   log_group_names = [aws_cloudwatch_log_group.order_api_access_log_group.name]
#   query_string = <<-EOT
#   stats pct(responseLatency, 50) as P50, pct(responseLatency, 99) as P99 by routeKey, bin(5m) as hist
#   | sort hist asc
#   EOT
# }

# resource "aws_cloudwatch_query_definition" "order_api_cold_start_and_memery" {
#   name = "${var.name_prefix}/order-api-cold-start-and-memery"
#   log_group_names = [aws_cloudwatch_log_group.order_api_log_group.name]
#   query_string = <<-EOT
#   filter @type = "REPORT" 
#   | stats count(@initDuration) as coldStarts, max(@maxMemoryUsed / 1000 / 1000) as maxMemMB, avg(@duration) as avgMs by bin(5m)
#   EOT
# }

# resource "aws_cloudwatch_query_definition" "order_worker_cold_start_and_memery" {
#   name = "${var.name_prefix}/order-worker-cold-start-and-memery"
#   log_group_names = [aws_cloudwatch_log_group.order_worker_log_group.name]
#   query_string = <<-EOT
#   filter @type = "REPORT" 
#   | stats count(@initDuration) as coldStarts, avg(@initDuration) as avgInitMs, max(@maxMemoryUsed / 1000 / 1000) as maxMemMB, avg(@duration) as avgMs by bin(5m)
#   EOT
# }