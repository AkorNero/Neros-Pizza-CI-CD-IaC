# Pricing, roughly (eu-west-1)
# Ingestion (Standard)	~$0.57 per GB
# Ingestion (Infrequent Access)	~$0.28 per GB
# Storage	~$0.03 per GB per month, which is why retention matters
# Logs Insights queries	~$0.0057 per GB scanned
# Free tier	5 GB of ingestion, storage and scanning per month

resource "aws_cloudwatch_log_group" "order_api_log_group" {
  name="/aws/lambda/order-api"
  retention_in_days = 14
  log_group_class = "STANDARD"
  # kms_key_id = 
}

resource "aws_cloudwatch_log_group" "order_worker_log_group" {
  name="/aws/lambda/order-worker"
  retention_in_days = 14
  log_group_class = "STANDARD"
  # kms_key_id = 
}

resource "aws_cloudwatch_log_group" "order_api_access_log_group" {
  name="/aws/apigateway/order-api-access"
  retention_in_days = 14
  log_group_class = "STANDARD"
  # kms_key_id = 
}