# How to run the terraform main.tf to create the database VM

## Initialize

$ cd on_prem/database
$ terraform init

## Test connection to VCSA in VMWare Lab (config in data03.tfvars)

$ terraform plan --var-file=data03.tfvars

## Create VM

$ terraform apply --var-file=data03.tfvars

## VM is now in production

Check the run.sh and run.log in /tmp, if needed

Manual command line to test DB:
psql postgresql://flask_user:Secret55@$hostip:5432/user_management_db

## Destroy VM (WARNING: VM cannot be recovered)

$ terraform destroy --var-file=data03.tfvars
