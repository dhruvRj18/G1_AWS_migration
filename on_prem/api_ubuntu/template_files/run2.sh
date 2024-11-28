#!/bin/bash
echo "=== Start of run 2 script ==="
hostname="$1"
hostip="$2"

# 5. Create a Systemd Service for GunicornCreate a Systemd Service for Gunicorn

sudo cat > /etc/systemd/system/flask_app.service <<EOF
[Unit]
Description=Gunicorn instance to serve flask_app
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu/flask_app
ExecStart=/usr/bin/gunicorn --workers 3 --bind unix:flask_app.sock -m 007 flask_app:app

[Install]
WantedBy=multi-user.target
EOF
ls -l /etc/systemd/system | grep flask_app

# 6. Start and enable the Gunicorn Service 
# Reload to recognize the new service file and start the flask_app (gunicorn) service
sudo systemctl daemon-reload
sudo systemctl start flask_app
sudo systemctl enable flask_app

# 7. Configure nginx to proxy requests to Gunicorn
# $hostip sample: 10.173.65.160 or 10.173.65.122 (api-vm)

sudo cat > /etc/nginx/sites-available/flask_app <<EOF
server {
    listen 80;
    server_name 10.173.65.122;

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/webuser/flask_app/flask_app.sock;
    }
}
EOF

# 8. Enable the nginx configuration

sudo ln -s /etc/nginx/sites-available/flask_app /etc/nginx/sites-enabled
ls -l /etc/nginx/sites-enabled

# 9. Test and reload nginx

sudo nginx -t
sudo systemctl restart nginx
sudo ufw allow 'Nginx Full'

echo "Flask installation and service creation complete!"

echo "=== End of run 2 script ==="
