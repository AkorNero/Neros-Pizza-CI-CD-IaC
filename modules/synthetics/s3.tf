resource "aws_s3_bucket" "canary_bucket" {
  bucket        = "${var.name_prefix}-synthetic-canary-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "canary_bucket_lifecycle" {
  bucket = aws_s3_bucket.canary_bucket.id
  rule {
    id     = "expire-artifacts"
    status = "Enabled"
    filter {} # applies to all objects
    expiration {
      days = var.artifact_expiration_days
    }
  }
}