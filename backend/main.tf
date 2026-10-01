terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  now = plantimestamp()
  bucket_name="terraform-state-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
}

provider "aws" {
  region = "eu-west-1"
  access_key = var.access_key
  secret_key = var.secret_key
  default_tags {
    tags = {
      Environment="Test",
      ManagesBy="Terraform"
      UpdatedAt   = local.now
    }
  }
}


resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = local.bucket_name
  force_destroy = true
  tags = {
    CreatedAt = timestamp()
  }

  lifecycle {
    ignore_changes = [tags["CreatedAt"]]
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_bucket_encryption" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# resource "aws_dynamodb_table" "terraform_state_lock" {
#   name = "terraform-state-lock"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
#   tags = {
#     CreatedAt = timestamp()
#   }

#   lifecycle {
#     ignore_changes = [tags["CreatedAt"]]
#   }
# }