terraform {
  backend "s3" {
    bucket       = "terraform-state-638331728031-eu-west-1"
    use_lockfile = true
    # dynamodb_table = "terraform-state-lock"
    key     = "nero's-pizza-infra-test/terraform-sns.tfstate"
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

provider "aws" {
  region     = "eu-west-1"
  access_key = var.access_key
  secret_key = var.secret_key
  default_tags {
    tags = {
      Environment = var.env,
      ManagedBy   = "terraform"
      Project     = "neros-pizza-test"
    }
  }
}

module "alerting" {
  source = "../../modules/alerting"
  alert_email = var.alert_email
}