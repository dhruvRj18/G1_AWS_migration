resource "aws_instance" "front_end" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id
  security_groups = [var.ec2_sg_id]
  key_name = "on-prem-key"

  user_data = <<-EOF
     #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install nginx1.12 -y
    sudo yum install -y git aws-cli
    sudo systemctl start nginx
    sudo systemctl enable nginx

    # Retrieve GitHub token from SSM Parameter Store
    TOKEN=$(aws ssm get-parameter --name "github_token" --with-decryption --query "Parameter.Value" --output text --region us-east-1)

    # Clone the GitHub repository using the token
    cd /usr/share/nginx/html
    sudo git clone https://$TOKEN@github.com/dhruvRj18/G1_AWS_migration.git .

    # Set up a cron job to pull updates every hour
    (crontab -l 2>/dev/null; echo "0 * * * * cd /usr/share/nginx/html && git pull") | crontab -
  EOF

  tags = {
    Name = "FrontEndInstance"
  }
}
