resource "aws_instance" "front_end" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id
  security_groups = [var.ec2_sg_id]
  key_name = "on-prem-key"

  user_data = <<-EOF
    #!/bin/bash
    # Update and install Nginx
    sudo yum update -y
    sudo yum install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx

    # Initial download of HTML files from GitHub
    sudo curl -o /usr/share/nginx/html/index.html https://raw.githubusercontent.com/dhruvRj18/G1_AWS_migration/refs/heads/main/webserver/index.html?token=GHSAT0AAAAAACZLQFCHC7JZ7U6ALC5CLSFKZZNG5GA
    sudo curl -o /usr/share/nginx/html/user_manage.html https://raw.githubusercontent.com/dhruvRj18/G1_AWS_migration/refs/heads/main/webserver/user_manage.html?token=GHSAT0AAAAAACZLQFCHGWDCWDRXA6UY3XPAZZNG6YA

    # Set up a cron job to update files every hour
    (crontab -l 2>/dev/null; echo "0 * * * * sudo curl -o /usr/share/nginx/html/index.html https://raw.githubusercontent.com/dhruvRj18/G1_AWS_migration/refs/heads/main/webserver/index.html?token=GHSAT0AAAAAACZLQFCHC7JZ7U6ALC5CLSFKZZNG5GA && sudo curl -o /usr/share/nginx/html/user_manage.html https://raw.githubusercontent.com/dhruvRj18/G1_AWS_migration/refs/heads/main/webserver/user_manage.html?token=GHSAT0AAAAAACZLQFCHGWDCWDRXA6UY3XPAZZNG6YA") | crontab -
  EOF
  tags = {
    Name = "FrontEndInstance"
  }
}
