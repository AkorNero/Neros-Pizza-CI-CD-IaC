# api, integration, routes, stage, lambda permission
resource "aws_apigatewayv2_api" "order_api" {
  name          = "${var.name_prefix}-order-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "order_api_integration" {
  api_id                 = aws_apigatewayv2_api.order_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.order_api.invoke_arn
  payload_format_version = "2.0"
}

locals {
  api_routes = toset([
    "POST /orders",
    "GET /health",
  ])
}

resource "aws_apigatewayv2_route" "order_api_order_route" {
  for_each  = local.api_routes
  api_id    = aws_apigatewayv2_api.order_api.id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.order_api_integration.id}"
}

resource "aws_apigatewayv2_stage" "order_api" {
  api_id      = aws_apigatewayv2_api.order_api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = var.access_log_group_arn
    format = jsonencode({
      requestId          = "$context.requestId"
      routeKey           = "$context.routeKey"
      status             = "$context.status"
      responseLatency    = "$context.responseLatency"
      integrationLatency = "$context.integrationLatency"
      integrationError   = "$context.integrationErrorMessage"
      sourceIp           = "$context.identity.sourceIp"
      requestTime        = "$context.requestTime"
    })
  }

  default_route_settings {
    detailed_metrics_enabled = true
    throttling_rate_limit    = 50
    throttling_burst_limit   = 100
  }
}

resource "aws_lambda_permission" "order_api_invoke_permission" {
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.order_api.execution_arn}/*/*"
  function_name = aws_lambda_function.order_api.function_name
}