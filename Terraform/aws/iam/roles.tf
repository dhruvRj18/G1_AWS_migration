# IAM Role for EC2 Instance
resource "aws_iam_role" "ec2_role" {
  name = "EC2SSMRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

# IAM Policy Document for EC2 to Assume Role
data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Attach SSM Parameter Access Policy to allow EC2 instance to retrieve the GitHub token
resource "aws_iam_role_policy" "ssm_parameter_access" {
  name = "EC2SSMParameterAccessPolicy"
  role = aws_iam_role.ec2_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter"
        ],
        Resource = "arn:aws:ssm:us-east-1:048836892613:parameter/github_token"  # Replace with your region and account ID
      }
    ]
  })
}

# Attach a managed policy to the role for basic EC2 instance profile permissions (optional but recommended)
resource "aws_iam_role_policy_attachment" "ec2_ssm_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# Instance Profile for the EC2 instance to use the above IAM role
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_role.name
}
