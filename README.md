# nodejs-aws-lambda-s3-thumbnail
Simple AWS Lambda to generate thumbnails to AWS S3 from images uploaded to AWS S3 using Terraform

Before deploy it, run `SHARP_IGNORE_GLOBAL_LIBVIPS=1 npm install --arch=x64 --platform=linux sharp` if not using Linux. 

Ref: https://sharp.pixelplumbing.com/install#aws-lambda.
