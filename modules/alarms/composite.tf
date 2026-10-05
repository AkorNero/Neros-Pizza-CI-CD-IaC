resource "aws_cloudwatch_composite_alarm" "comp_alarm" {
  alarm_name = "${var.name_prefix}-user-facing-breakage-critical"
  alarm_description = "USER IMPACT: orders API is failing for customers (5xx rate above ${var.thresholds.api_5xx_rate_percent}% and/or the synthetic canary is failing). Open the ops dashboard, check which child alarm is in ALARM, then work through the warning alarms (Lambda errors, DynamoDB, throttles, latency) to find the cause. Rollback is the first option if this started after a deploy."
  alarm_rule = join(" OR ", [for n in local.page_alarm_names : "ALARM(\"${n}\")"])
  alarm_actions = [local.topics["critical"]]
  ok_actions = [local.topics["critical"]]
  # mutes the page during planned work.
  # actions_suppressor { 
  #   alarm = <maintenance alarm>, 
  #   extension_period = 60, 
  #   wait_period = 60 
  # } 
}