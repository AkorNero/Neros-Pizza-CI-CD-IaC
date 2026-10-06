data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "archive_file" "canary_zip" {
  type        = "zip"
  output_path = "${path.root}/.build/canary.zip"
  source {
    content  = file("${path.root}/../../app/canary/index.js")
    filename = "nodejs/node_modules/index.js"
  }
}