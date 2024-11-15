# Setting up VMs on-premises.

## Front-End VM
1. Launch Ubuntu VM 
2. Install nginx by using these commands - 
   3. sudo apt update -y
   4. sudo apt install nginx -y
   5. sudo systemctl start nginx
   6. sudo systemctl enable nginx
5. check if nginx is running using this command -
   7. sudo systemctl status nginx
8. Create Directory for Your Website - 
   9. sudo mkdir -p /var/www/html 
10. Set Permissions - 
    11. sudo chown -R $USER:$USER /var/www/html
12. Add HTML Files - 
    13. export GITHUB_TOKEN="<git token>"
    14.     sudo curl -H "Authorization: token $GITHUB_TOKEN" -o /var/www/html/index.html "https://raw.githubusercontent.com/dhruvRj18/G1_AWS_migration/refs/heads/main/webserver/index.html"
    15.     sudo curl -H "Authorization: token $GITHUB_TOKEN" -o /var/www/html/user_manage.html "https://raw.githubusercontent.com/dhruvRj18/G1_AWS_migration/refs/heads/main/webserver/user_manage.html"
16.  Configure Nginx to Serve Your Website
    17. sudo nano /etc/nginx/sites-available/html
    17. Add the configuration from below
17. Enable the Configuration
    18. sudo ln -s /etc/nginx/sites-available/html /etc/nginx/sites-enabled/
19. Test Nginx Configuration
    20. sudo nginx -t
    21. sudo systemctl restart nginx
22. Open Firewall
    23. sudo ufw allow 'Nginx HTTP'
    24. sudo ufw enable
25. Access the Website
    26. open your browser and go to http://your_domain_or_ip




### Enginx config for front-end 

 ```json
 server {
        listen 80;
        server_name your_domain_or_ip;

        root /var/www/html;
        index index.html;

        location / {
            try_files $uri $uri/ =404;
        }
}
```


## Setting up backend-VM
1. Launch Ubuntu VM 
2. Copy files from flask_app folder using winscp
3. Install python pip,nginx and libraries
   4. sudo apt update
   5. sudo apt install python3-pip  nginx -y
   6. pip3 install -r requirements.txt
7. Test the Flask Application
   8. gunicorn --bind 0.0.0.0:5000 flask_app:app
9. Create a Systemd Service for Gunicorn
   10. sudo nano /etc/systemd/system/flask_app.service
   11. add lines from below
   12. sudo usermod -aG your_username www-data
12. Start and Enable the Gunicorn Service
    13. sudo systemctl start flask_app
    14. sudo systemctl enable flask_app
15.  Configure Nginx to Proxy Requests to Gunicorn
    16. sudo nano /etc/nginx/sites-available/flask_app
    16. Add configurations from below
16. Enable the Nginx Configuration
    17. sudo ln -s /etc/nginx/sites-available/flask_app /etc/nginx/sites-enabled/
18. Test and Reload Nginx
    19. sudo nginx -t
    20. sudo systemctl restart nginx
    21. sudo ufw allow 'Nginx Full'
22. Access Your Flask Application
    23. http://your_domain_or_ip



### Flask_app.service configs
```
[Unit]
Description=Gunicorn instance to serve flask_app
After=network.target

[Service]
User=your_username
Group=your_username
WorkingDirectory=/home/your_username/Desktop
ExecStart=/usr/bin/gunicorn --workers 3 --bind unix:flask_app.sock -m 007 flask_app:app

[Install]
WantedBy=multi-user.target


```

### nginx config for backend
```json
server {
    listen 80;
    server_name your_domain_or_ip;

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/your_username/flask_app/flask_app.sock;
    }
}

```

## Database VM setup
1. Launch ubuntu machine
2. Install postgresql
   3. sudo apt update
   4. sudo apt install postgresql postgresql-contrib -y
   5. sudo systemctl start postgresql
   6. sudo systemctl enable postgresql
7.  Switch to the PostgreSQL User
   8. sudo -i -u postgres
   9. psql
   10. CREATE DATABASE user_management_db;
   11. CREATE USER flask_user WITH PASSWORD 'Secret55';
   12. GRANT ALL PRIVILEGES ON DATABASE user_management_db TO flask_user;
13. Connect to the New Database
    14. \c user_management_db
    15. CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash TEXT NOT NULL
);
    16. GRANT ALL PRIVILEGES ON TABLE users TO flask_user;
    17. GRANT USAGE, SELECT, UPDATE ON SEQUENCE users_id_seq TO flask_user;
    17. \q
    18. exit
19. Configure PostgreSQL for External Access
    20. sudo nano /etc/postgresql/*/main/postgresql.conf
    21. Look for the listen_addresses setting and change it to: listen_addresses = '*'
    22. Edit the Client Authentication File (pg_hba.conf):
        23. sudo nano /etc/postgresql/*/main/pg_hba.conf
        24. Change IPv4 local connection address from localhost to 0.0.0.0/0 to allow all connections
        26. sudo systemctl restart postgresql
27. sudo ufw allow 5432/tcp
28. Test the Connection
    29. psql -h your_server_ip -U flask_user -d user_management_db -W

       

