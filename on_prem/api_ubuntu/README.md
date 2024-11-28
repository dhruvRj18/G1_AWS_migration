# How to prepare the API tier on VMWare Lab

## Important notes

- Pre-req: You must have taken SYST8111 and know how to clone/create an Ubuntu VM

- The use of python tensorflow package can only be done on the Ubuntu VM running on the college vCenter.

- There are constraints (e.g., create resource permissions) in the use of Terraform to create VMs on the college vCenter.

- As such, the cloning of template is done with a few basic steps without Terraform.

## 1. Connect to college VCSA

- URL: https://wtcsit3avc-vcsa03.conestogac.on.ca/
- Use your college email and password

## 2. Clone a new Ubuntu VM

- Power OFF any existing x.y.z.122 VM (avoids IPv4 conflict of new VM)
- Locate a template (e.g., ubt_122_template)
- New VM from This Template..
- Host Name: cc-api-ubt02 (hostname)
- Host IP: 10.173.65.122 (hostip)
- Power ON the new VM

## 3. Pre-install check (change host name and check IPv4)

- Start a new SSH Terminal 1 ($hostip: e.g., 10.173.65.122)
- Login as ubuntu / Secret55
- Manually execute these commands:
  $ hostname=cc-api-ubt02
  $ hostnamectl set-hostname $hostname
$ hostname
  $ uname -a
  $ ip a
  $ shutdown -h now

## 4. Prepare run script #1 and execute

- Copy template_files/run_api_1.sh.tpl to new VM /tmp/run1.sh
- Modify the /tmp/run1.sh (as needed)

- Manual steps: ./run1.sh $hostname $hostip (e.g., ./run1.sh cc-api-ubt02 10.173.65.122)
- $ gunicorn --bind 0.0.0.0:5000 flask_app:app

## 5. Test the Flask service: GET method only

- Start a new SSH Terminal 2 ($hostip: e.g., 10.173.65.122)
- Expected response: {"message":"Flask Service is running","status":"healthy"}

- 5a. Test on localhost (new ubt02 VM):
  - curl http://localhost:5000/health
- 5b. Test from another VM (e.g., front01 VM or IP 10.173.65.51)

  - curl http://$hostip:5000/health (e.g., curl http://10.173.65.122:5000/health)

- Note: Do not continue until the above test cases are satisfied

## 6. Prepare run script #2 and execute

- Stop the "gunicorn flask_app:app" server #4 (Terminal 1 above)

- Copy template_files/run_api_2.sh.tpl to new VM /tmp/run2.sh
- Modify the /tmp/run2.sh (as needed)

- Manual steps: ./run2.sh $hostname $hostip (e.g., ./run2.sh cc-api-ubt02 10.173.65.122)

## 7. Test the Flask app on the new VM (command line)

- Repeat Test cases 1 and 2 from 5a and 5b above
- Test case 3: Register a new user (POST method): replace with $hostip below
$ curl -X POST http://10.173.65.122:5000/register -H "Content-Type: application/json" -d '{
  "username": "r122",
  "email": "r122@example.com",
  "password": "password123"
  }'

## 8. Test the Flask app using the web browser

- If test cases in #7 above passed:
- Repeat Test case 2 from 5b above
- Repeat Test case 3 from 7 above
