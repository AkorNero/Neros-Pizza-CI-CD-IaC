resource "aws_cloudwatch_log_data_protection_policy" "email_redaction_policy" {
  log_group_name = aws_cloudwatch_log_group.order_api_log_group.name

  policy_document = jsonencode({
    Version = "2021-06-01"
    Name        = "${var.name_prefix}-email-protection"
    Description = "Mask customer emails in order API logs"
    Statement = [
      {
        Sid            = "Audit"
        DataIdentifier = ["arn:aws:dataprotection::aws:data-identifier/EmailAddress"]
        Operation = {
          Audit = {
            FindingsDestination = {}
          }
        }
      },
      {
        Sid            = "Redact"
        DataIdentifier = ["arn:aws:dataprotection::aws:data-identifier/EmailAddress"]
        Operation = {
          Deidentify = {
            MaskConfig = {}
          }
        }
      }
    ]
  })
}