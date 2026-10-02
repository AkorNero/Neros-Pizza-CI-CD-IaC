resource "aws_dynamodb_table" "order_table" {
  name         = "${var.name_prefix}-order-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "orderId"
  attribute {
    name = "orderId"
    type = "S"
  }
}