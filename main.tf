# Simple AWS Lambda Terraform Example
# requires 'index.js' in the same directory
# to test: run `terraform plan`
# to deploy: run `terraform apply`

variable "aws_region" {
  default = "sa-east-1"
}

variable "environment" {
  default = "dev"
}

terraform {
  backend "s3" {
    bucket = "viniciusls-terraform"
    key    = "nodejs-aws-lambda-s3-thumbnail/terraform.tfstate"
    region = "sa-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3-proxy-gateway" {
  source      = "./s3-proxy-gateway"
  environment = var.environment
  region      = var.aws_region
}

