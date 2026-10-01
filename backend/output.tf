output "state_bucket_name" {
  description = "The bucket name of the backend"
  value = local.bucket_name
}

# output "state_dynamodb_lock" {
#   description = "The dynamodb name for the lock"
#   value = aws_dynamodb_table.terraform_state_lock.name
# }