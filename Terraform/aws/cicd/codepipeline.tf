resource "aws_codepipeline" "front_end_pipeline" {
  name     = "front-end-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    type     = "S3"
    location = var.pipeline_bucket_name
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "Dhruv"
        Repo       = "G1_AWS_migration"
        Branch     = "main"
        OAuthToken = "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"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.front_end_build.name
      }
    }
  }
}
