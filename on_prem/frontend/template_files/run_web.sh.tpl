#!/bin/bash
echo "=== Start of run script ==="
hostname="$1"
hostip="$2"

hostnamectl set-hostname $hostname 
hostname
uname -a

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

sudo cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
EOF

# Update system packages
dnf update -y

# Install Apache Web Server
dnf install -y httpd

# Start and enable httpd service
systemctl enable httpd
systemctl start httpd

# Create directory for user management website
mkdir -p /var/www/html
chown -R $USER:$USER /var/www/html

# Download html files from github
export GITHUB_TOKEN="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"
sudo curl -H "Authorization: token $GITHUB_TOKEN" -o /var/www/html/index.html "https://raw.githubusercontent.com/dhruvRj18/G1_AWS_migration/refs/heads/main/webserver/index.html"
sudo curl -H "Authorization: token $GITHUB_TOKEN" -o /var/www/html/user_manage.html "https://raw.githubusercontent.com/dhruvRj18/G1_AWS_migration/refs/heads/main/webserver/user_manage.html"

# Configure firewall to allow HTTP traffic
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# Test the http connection
curl http://$hostip

echo "Web Server installation complete!"

echo "=== End of run script ==="
