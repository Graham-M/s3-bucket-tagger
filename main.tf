resource "aws_lambda_function" "lambda_s3_bucket_tagger" {
  filename = "${path.module}/lambda_s3_bucket_tagger.zip"
  function_name = "s3-bucket-tagger"
  source_code_hash = "${data.archive_file.lambda_s3_bucket_tagger_zip.output_base64sha256}"
  role = "${aws_iam_role.s3_bucket_tagger_role.arn}"
  handler = "lambda_s3_bucket_tagger.lambda_handler"
  runtime = "python2.7"
  timeout = "30"
  memory_size = "256"
}

resource "aws_lambda_permission" "lambda_s3_bucket_tagger_cloudwatch_permission" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.lambda_s3_bucket_tagger.function_name}"
  principal      = "events.amazonaws.com"
  source_account = "${data.aws_caller_identity.current.account_id}"
  source_arn     = "${aws_cloudwatch_event_rule.schedule_lambda_s3_bucket_tagger.arn}"
}

resource "aws_cloudwatch_event_rule" "schedule_lambda_s3_bucket_tagger" {
  name                = "schedule-lambda-s3_bucket-tagger"
  description         = "Schedule lambda s3 bucket tagger"
  schedule_expression = "rate(12 hours)"
}

resource "aws_cloudwatch_event_target" "lambda_s3_bucket_tagger_invoke" {
  rule      = "${aws_cloudwatch_event_rule.schedule_lambda_s3_bucket_tagger.name}"
  arn       = "${aws_lambda_function.lambda_s3_bucket_tagger.arn}"
}

resource "aws_iam_role" "s3_bucket_tagger_role" {
  name = "s3_bucket_tagger_role"

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
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "s3_bucket_tagger_policy" {
  name = "s3-bucket-tagger-policy"
  role = "${aws_iam_role.s3_bucket_tagger_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:List*",
        "s3:PutBucketTagging",
        "s3:GetBucketTagging",
        "s3:DeleteBucketTagging"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
