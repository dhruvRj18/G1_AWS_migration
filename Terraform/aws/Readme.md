# Steps for Terraform AWS infrastructure

- On AWS console, EC2, create a new key pair named "on-prem-key"
- Save your aws credentials (access key and secret) in your aws config with profile name "grp_ass"
- Terraform init
- Terraform plan (you will be asked for git token, contact Dhruv for this)
- Terraform apply

Wait for the resources to be created - 
- VPC
- NAT Gateway
- Internet Gateway
- Subnets (2 public, 1 private)
- EC2 instances (1 Fontend, 1 bastion host)
- Load balancer
- Security Groups

Once created, check if nginx is running on frontend instnce. You will not be able to ssh into it directly as it is in private subnet.
Hence, ssh into the bastion host with pem key. then copy your pem key into the bastion host machine. 
Now you can ssh into the frontend instance using its private ip from the ssh session opened on bastion host. 

Run these commands to check if nginx is running.

- sudo systemctl status nginx
  - If this is not running, run sudo systemctl start nginx
  - If it throws the error of nginx not being installed, you will need to run commands from ect_instances.tf file
  - Run commands one-by one 
    - sudo yum update -y
    - sudo amazon-linux-extras install nginx1 -y
    - sudo systemctl start nginx
    - sudo systemctl enable nginx
    - export GITHUB_TOKEN="<toekn_taken_from_dhruv>"
    - sudo curl -H "Authorization: token $GITHUB_TOKEN" -o /usr/share/nginx/html/index.html "https://raw.githubusercontent.com/dhruvRj18/G1_AWS_migration/refs/heads/main/webserver/index.html"
    - sudo curl -H "Authorization: token $GITHUB_TOKEN" -o /usr/share/nginx/html/user_manage.html "https://raw.githubusercontent.com/dhruvRj18/G1_AWS_migration/refs/heads/main/webserver/user_manage.html"
    - (crontab -l 2>/dev/null; echo "0 * * * * curl -H 'Authorization: token $GITHUB_TOKEN' -o /usr/share/nginx/html/index.html 'https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$BRANCH/$FILE_PATH_1' && curl -H 'Authorization: token $GITHUB_TOKEN' -o /usr/share/nginx/html/user_manage.html 'https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$BRANCH/$FILE_PATH_2'") | crontab -
  - Check if the files are copied into the html folder.
  - sudo systemctl restart nginx
  - curl http://localhost/index.html (This should show content of html file, if fails contact dhruv)



Now the load balancer target group health checks should be passing and it should be healthy. 
Go to EC2 > Load balancer > open load balancer and copy dns to another tab and you should be able to see html page. 


Don't forget to run terraform destroy to delete all the resources after you are done. 
