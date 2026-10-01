terraform {
  backend "s3" {
    bucket       = "terraform-state-638331728031-eu-west-1"
    use_lockfile = true
    # dynamodb_table = "terraform-state-lock"
    key     = "nero's-pizza-infra-test/terraform.tfstate"
    encrypt = true
    region  = "eu-west-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  now = plantimestamp()
}

provider "aws" {
  region     = "eu-west-1"
  access_key = var.access_key
  secret_key = var.secret_key
  default_tags {
    tags = {
      Environment = var.env,
      ManagedBy   = "terraform"
      UpdatedAt   = local.now
      Project     = "nero-s-pizza"
    }
  }
}

module "workload" {
  source = "../../modules/workload"
}