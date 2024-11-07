resource "aws_codebuild_project" "front_end_build" {
  name          = "front-end-build"
  source {
    type      = "GITHUB"
    location  = "https://github.com/yourusername/yourrepo"
    buildspec = <<EOF
    version: 0.2

    phases:
      install:
        runtime-versions:
          nodejs: 14
        commands:
          - echo "Installing Nginx and copying HTML files"
      post_build:
        commands:
          - echo "Build completed"
    EOF
  }
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
  }
}