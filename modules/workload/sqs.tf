# main queue + DLQ
resource "aws_sqs_queue" "dead_letter_queue" {
  name                      = "${var.name_prefix}-dql"
  message_retention_seconds = 1209600 # 14 days: time to investigate (maximum possible time frame)
}

resource "aws_sqs_queue" "order_queue" {
  name                       = "${var.name_prefix}-order-queue"
  visibility_timeout_seconds = 6 * var.worker_timeout_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_redrive_allow_policy" "order_queue_allow_policy" {
  queue_url = aws_sqs_queue.order_queue.id
  redrive_allow_policy = jsonencode({
    redrivePermission = "denyAll"
  })
}

resource "aws_sqs_queue_redrive_allow_policy" "dead_letter_queue_allow_policy" {
  queue_url = aws_sqs_queue.dead_letter_queue.id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.order_queue.arn]
  })
}