# Simple AWS Lambda Terraform Example
# requires 'index.js' in the same directory
# to test: run `terraform plan`
# to deploy: run `terraform apply`

terraform {
  backend "s3" {
    bucket = "viniciusls-terraform"
    key    = "nodejs-aws-lambda-s3-thumbnail"
    region = "sa-east-1"
  }
}

variable "aws_region" {
  default = "sa-east-1"
}

provider "aws" {
  region = var.aws_region
}
