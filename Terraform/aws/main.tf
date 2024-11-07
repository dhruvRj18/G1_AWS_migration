module "vpc" {
  source = "./vpc"
}

module "ec2" {
  source = "./ec2"
}

module "cicd" {
  source = "./cicd"
}

module "iam" {
  source = "./iam"
}

module "s3" {
  source = "./s3"
}
