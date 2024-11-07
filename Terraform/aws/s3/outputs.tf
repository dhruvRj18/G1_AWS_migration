output "pipeline_bucket_name" {
  value = aws_s3_bucket.pipeline_bucket.bucket
}
output "deployment_bucket_name" {
  value = aws_s3_bucket.deployment_bucket.bucket
}