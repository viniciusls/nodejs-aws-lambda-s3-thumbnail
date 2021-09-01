variable "s3_bucket_images" {
  default = "vini-images-example"
}

resource "aws_s3_bucket" "vini-images-example" {
  bucket = var.s3_bucket_images
}

resource "aws_s3_bucket_notification" "bucket_notification_png" {
  bucket = aws_s3_bucket.vini-images-example.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.aws_lambda_s3_thumbnail.arn
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_prefix = "images/"
    filter_suffix = ".png"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.aws_lambda_s3_thumbnail.arn
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_prefix = "images/"
    filter_suffix = ".jpg"
  }

  depends_on = [
    aws_lambda_permission.allow_bucket
  ]
}
