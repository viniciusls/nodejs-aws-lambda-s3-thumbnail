# Simple AWS Lambda Terraform Example
# requires 'index.js' in the same directory
# to test: run `terraform plan`
# to deploy: run `terraform apply`

variable "aws_region" {
  default = "us-west-2"
}

provider "aws" {
  region          = var.aws_region
}

data "archive_file" "lambda_zip" {
  type          = "zip"
  source_file   = "index.js"
  output_path   = "aws_lambda_s3_thumbnail.zip"
}

resource "aws_iam_role" "iam_for_lambda_tf" {
  name = "iam_for_lambda_tf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    },
    {
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:PutObject"
      ]
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Resource": [
        "arn:aws:s3:::vini-images-example/*",
      ]
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.vini-images-example.arn
}

resource "aws_lambda_function" "aws_lambda_s3_thumbnail" {
  filename         = "aws_lambda_s3_thumbnail.zip"
  function_name    = "aws_lambda_s3_thumbnail"
  role             = aws_iam_role.iam_for_lambda_tf.arn
  handler          = "app.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "nodejs14.x"
}

resource "aws_s3_bucket" "vini-images-example" {
  bucket = "vini-images-example"
}

resource "aws_s3_bucket_notification" "bucket_notification_png" {
  bucket = aws_s3_bucket.vini-images-example.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "images/"
    filter_suffix       = ".png"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_s3_bucket_notification" "bucket_notification_jpg" {
  bucket = aws_s3_bucket.vini-images-example.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "images/"
    filter_suffix       = ".jpg"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
