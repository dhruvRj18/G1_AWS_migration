output "ec2_role_arn" {
  value = aws_iam_role.ec2_role.arn
  description = "ARN of the IAM role assigned to the EC2 instance"
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
  description = "Name of the IAM instance profile assigned to the EC2 instance"
}
