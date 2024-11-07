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
    sudo systemctl start nginx
    sudo systemctl enable nginx

    # Pull HTML files from GitHub repo (simplified for example)
    sudo curl -o /usr/share/nginx/html/index.html https://raw.githubusercontent.com/dhruvRj18/G1_AWS_migration/refs/heads/main/webserver/index.html?token=GHSAT0AAAAAACZLQFCGV2X4X3O4UE2I5DIKZZM7GNA
    sudo curl -o /usr/share/nginx/html/user_manage.html https://raw.githubusercontent.com/dhruvRj18/G1_AWS_migration/refs/heads/main/webserver/user_manage.html?token=GHSAT0AAAAAACZLQFCG2R5APLMHUC57OQ4AZZM7GUA
  EOF

  tags = {
    Name = "FrontEndInstance"
  }
}
