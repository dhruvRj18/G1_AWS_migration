#!/bin/bash
echo "=== Start of run 1 script ==="
hostname="$1"
hostip="$2"

hostnamectl set-hostname $hostname 
hostname
uname -a

sudo apt update

sudo apt install -y open-vm-tools
vmware-toolbox-cmd -v

cd $home
cd flask_app/
ls -l flask_app.py
cat flask_app.py | grep 173
cat flask_app.py | grep health 

sudo apt install -y python3
python3 --version

sudo apt install -y python3-pip nginx
pip --version
sudo nginx -t

pip3 install -r requirements.txt
sudo apt install -y gunicorn
gunicorn --version
pip freeze | grep Flask

# check the IP of data03 VM
pwd
cat flask_app.py | grep 173
sed -i 's/10.173.54.163/10.173.65.53/g' flask_app.py
cat flask_app.py | grep 173

# Temporary Check: gunicorn --bind 0.0.0.0:5000 flask_app:app

echo "Flask installation complete!"

echo "=== End of run 1 script ==="
