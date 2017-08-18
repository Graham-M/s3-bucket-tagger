# s3-bucket-tagger

AWS's Cost Explorer allows you to break down S3 costs by API call type, not by bucket name.

This terraform/lambda/cloudwatch events combo will tag all buckets, every 12 hours, with a tag of `bucket_name`.
