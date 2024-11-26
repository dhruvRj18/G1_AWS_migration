# How to run the terraform main.tf to create the web VM

## Initialize

change directory (cd) to on_prem/frontend
$ terraform init

## Test connection to VCSA in VMWare Lab (config in front01.tfvars)

$ terraform plan --var-file=front01.tfvars

## Create VM

$ terraform apply --var-file=front01.tfvars

## VM is now in production

Check the run.sh and run.log in /tmp, if needed

Manual command line to test http connection:
curl "http://$hostip:80/"

## Destroy VM (WARNING: VM cannot be recovered)

$ terraform destroy --var-file=front01.tfvars
