resource "aws_instance" "front_end" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id
  security_groups = [var.ec2_sg_id]
  key_name = "on-prem-key"

  user_data = <<-EOF
    #!/bin/bash
    # Function to check internet connectivity
    check_internet() {
      for i in {1..10}; do
        if ping -c 1 8.8.8.8 &> /dev/null; then
          echo "Internet connection established."
          return 0
        else
          echo "Waiting for internet connection..."
          sleep 10
        fi
      done
      echo "Internet connection could not be established. Exiting."
      exit 1
    }

    # Wait for internet connection through NAT gateway
    check_internet

    # Update and install Nginx
    sudo yum update -y
    sudo amazon-linux-extras install nginx1 -y
    sudo systemctl start nginx
    sudo systemctl enable nginx

    export GITHUB_TOKEN="${var.github_pat}"
    
    # Initial download of HTML files from GitHub
    sudo curl -H "Authorization: token $GITHUB_TOKEN" -o /usr/share/nginx/html/index.html "https://raw.githubusercontent.com/dhruvRj18/G1_AWS_migration/refs/heads/main/webserver/index.html"
    sudo curl -H "Authorization: token $GITHUB_TOKEN" -o /usr/share/nginx/html/user_manage.html "https://raw.githubusercontent.com/dhruvRj18/G1_AWS_migration/refs/heads/main/webserver/user_manage.html"

    # Set up a cron job to update files every hour
    (crontab -l 2>/dev/null; echo "0 * * * * curl -H 'Authorization: token $GITHUB_TOKEN' -o /usr/share/nginx/html/index.html 'https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$BRANCH/$FILE_PATH_1' && curl -H 'Authorization: token $GITHUB_TOKEN' -o /usr/share/nginx/html/user_manage.html 'https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$BRANCH/$FILE_PATH_2'") | crontab -
  EOF
  tags = {
    Name = "FrontEndInstance"
  }
}


resource "aws_instance" "bastion_host"{
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id_a
  key_name = "on-prem-key"
  security_groups = [var.ec2_sg_bastion_id]
   tags = {
    Name = "bastion-host"
  }

}