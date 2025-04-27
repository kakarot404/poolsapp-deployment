provider "aws" {
  region = "us-east-1"                                                  # Specifying desired AWS region here
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "pools.app-bucket-by-terraform"                      # Ensuring this is globally unique name

  tags = {
    Name        = "App-Bucket"
    Environment = "Production"
  }
}

                                                                # Separate resource for managing ACL on the S3 bucket
resource "aws_s3_bucket_acl" "app_bucket_acl" {
  bucket = aws_s3_bucket.app_bucket.bucket
  acl    = "private"                                            # Defining the ACL separately
  depends_on = [aws_s3_bucket.app_bucket]                       # To Ensure the bucket is created first
}

resource "time_sleep" "wait_for_s3_bucket" {
  depends_on = [aws_s3_bucket.app_bucket]
  create_duration = "30s"                                       # To delay for 30 seconds before proceeding
}

                                                                # Separate resource for managing versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.bucket

  versioning_configuration {
    status = "Enabled"                                          # Enabling versioning
  }

  depends_on = [aws_s3_bucket.app_bucket]                       # Providing dependency so the bucket is created first
}
