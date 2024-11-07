resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "g4_frontend"
  acl    = "private"
}
