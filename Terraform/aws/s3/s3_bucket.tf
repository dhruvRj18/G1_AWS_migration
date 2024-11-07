resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "g1-frontend-risk-analyser-frontend-webserver"
}
resource "aws_s3_bucket_acl" "pipeline_bucket_acl" {
  bucket = aws_s3_bucket.pipeline_bucket.id
  acl    = "private"
}
