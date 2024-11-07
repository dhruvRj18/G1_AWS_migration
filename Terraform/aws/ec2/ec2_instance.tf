resource "aws_instance" "front_end" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id
  security_groups = [aws_security_group.ec2_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install nginx1.12 -y
    sudo systemctl start nginx
    sudo systemctl enable nginx

    # Pull HTML files from GitHub repo (simplified for example)
    sudo curl -o /usr/share/nginx/html/index.html https://raw.githubusercontent.com/yourusername/yourrepo/main/index.html
    sudo curl -o /usr/share/nginx/html/user_manage.html https://raw.githubusercontent.com/yourusername/yourrepo/main/user_manage.html
  EOF

  tags = {
    Name = "FrontEndInstance"
  }
}
