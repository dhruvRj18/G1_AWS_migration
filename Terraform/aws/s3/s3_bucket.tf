resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "g1-frontend-risk-analyser-frontend-webserver"
}
resource "aws_s3_bucket_acl" "pipeline_bucket_acl" {
  bucket = aws_s3_bucket.pipeline_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket" "deployment_bucket" {
  bucket = "g1-frontend-deployment-123456"  # Ensure this name is globally unique
}
resource "aws_s3_bucket_acl" "deployment_bucket_acl" {
  bucket = aws_s3_bucket.deployment_bucket.id
  acl    = "public-read"  # Set this to public-read if files need to be publicly accessible
}