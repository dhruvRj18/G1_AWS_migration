variable "codepipeline_role_arn" {
  description = "The ARN of the IAM role for CodePipeline"
  type        = string
}

variable "pipeline_bucket_name" {
  description = "The name of the S3 bucket for CodePipeline artifacts"
  type        = string
}

variable "codebuild_role_arn" {
  description = "The ARN of the IAM role for CodeBuild"
  type        = string
}
