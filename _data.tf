data "aws_caller_identity" "current" {}

data "archive_file" "lambda_s3_bucket_tagger_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_s3_bucket_tagger/"
  output_path = "${path.module}/lambda_s3_bucket_tagger.zip"
}
