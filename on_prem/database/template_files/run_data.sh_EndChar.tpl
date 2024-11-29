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

# Install PostgreSQL 15 repository and packages
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
dnf module disable -y postgresql
dnf install -y postgresql15-server postgresql15-contrib

# Initialize PostgreSQL database
/usr/pgsql-15/bin/postgresql-15-setup initdb

# Start and enable PostgreSQL service
systemctl enable postgresql-15
systemctl start postgresql-15

# Switch to postgres user to create database and table
sudo -u postgres psql <<EOF
-- Create a new database
CREATE DATABASE user_management_db;
CREATE USER flask_user WITH PASSWORD 'Secret55';
GRANT ALL PRIVILEGES ON DATABASE user_management_db TO flask_user;

-- Connect to the new database
\c user_management_db

-- Create Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL
);

GRANT ALL PRIVILEGES ON TABLE users TO flask_user;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE users_id_seq TO flask_user;

-- insert a user
INSERT INTO users (username, email, password_hash) 
VALUES ('Dhruv', 'dparmar1628@conestogac.on.ca', 'scrypt:32768:8:1$M1CPWxgA2Nh2QpJ4$0c5e3b2fab6030972c32d865d68b4adb22081c14331b14eb44f97fe49a6765ae9c112c0432d8433dce8b20d857e7030ac9c982574ea4a495e8529663639f6e09');

EOF

# Configure PostgreSQL for External Access on Rocky Linux
cd /var/lib/pgsql/15/data

# file 1: postgresql.conf

# confirm conf file found
cat postgresql.conf | grep localhost

# backup conf file
cp postgresql.conf postgresql.conf.bak

# replace conf to remove hash
sed -i '0,/#listen_addresses/s/#listen_addresses/listen_addresses/' postgresql.conf

# confirm hash removed
cat postgresql.conf | grep localhost

# replace the first localhost with *
sed -i '0,/localhost/s/localhost/*/' postgresql.conf

# confirm first localhost was replaced
cat postgresql.conf | grep listen_addresses

# confirm second localhost was not replaced
cat postgresql.conf | grep localhost

# file 2: pg_hba.conf
cat pg_hba.conf | grep 127.0.0.1
cp pg_hba.conf pg_hba.conf.bak
sed -i '0,/127.0.0.1/s/127.0.0.1/0.0.0.0/' pg_hba.conf
cat pg_hba.conf | grep 0.0.0.0/32
sed -i 's@0.0.0.0/32@0.0.0.0/0@g' pg_hba.conf
cat pg_hba.conf | grep 0.0.0.0/0

# Restart service after conf changes
systemctl restart postgresql-15

# Add tcp port to firewall
firewall-cmd --list-all | grep tcp
firewall-cmd --add-port=5432/tcp --permanent
firewall-cmd --reload
firewall-cmd --list-all | grep tcp

# Test the Connection on port 5432 using $hostip argument
psql postgresql://flask_user:Secret55@$hostip:5432/user_management_db << EOF
\q
EOF

echo "PostgreSQL installation and User table creation complete!"

echo "=== End of run script ==="
