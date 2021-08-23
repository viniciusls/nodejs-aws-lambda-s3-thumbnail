# Simple AWS Lambda Terraform Example
# requires 'index.js' in the same directory
# to test: run `terraform plan`
# to deploy: run `terraform apply`

variable "aws_region" {
  default = "sa-east-1"
}

provider "aws" {
  region = var.aws_region
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source_dir = path.module
  output_path = "aws_lambda_s3_thumbnail.zip"
  excludes = [
    "aws_lambda_s3_thumbnail.zip",
    ".git",
    ".gitignore",
    ".idea",
    ".terraform",
    ".terraform.lock.hcl",
    "terraform.tfstate",
    ".terraform.tfstate.lock.info",
    "lambda.tf",
    "LICENSE",
    "README.md",
    "yarn.lock"]
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole"]
        Principal = {
          Service: "lambda.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })

  managed_policy_arns = [aws_iam_policy.s3_iam_bucket_policy.arn]
}

resource "aws_iam_policy" "s3_iam_bucket_policy" {
  name = "s3_iam_bucket_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:PutObject"]
        Principal = {
          Service: "lambda.amazonaws.com"
        },
        Effect = "Allow"
        Resource = "arn:aws:s3:::vini-images-example/*"
      },
    ]
  })
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aws_lambda_s3_thumbnail.arn
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.vini-images-example.arn
}

resource "aws_lambda_function" "aws_lambda_s3_thumbnail" {
  filename = "aws_lambda_s3_thumbnail.zip"
  function_name = "aws_lambda_s3_thumbnail"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "app.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime = "nodejs14.x"
}

resource "aws_s3_bucket" "vini-images-example" {
  bucket = "vini-images-example"
}

resource "aws_s3_bucket_notification" "bucket_notification_png" {
  bucket = aws_s3_bucket.vini-images-example.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.aws_lambda_s3_thumbnail.arn
    events = [
      "s3:ObjectCreated:*"]
    filter_prefix = "images/"
    filter_suffix = ".png"
  }

  depends_on = [
    aws_lambda_permission.allow_bucket]
}

resource "aws_s3_bucket_notification" "bucket_notification_jpg" {
  bucket = aws_s3_bucket.vini-images-example.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.aws_lambda_s3_thumbnail.arn
    events = [
      "s3:ObjectCreated:*"]
    filter_prefix = "images/"
    filter_suffix = ".jpg"
  }

  depends_on = [
    aws_lambda_permission.allow_bucket]
}
