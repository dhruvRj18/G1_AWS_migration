module "vpc" {
  source               = "./vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr_a = var.public_subnet_cidr_a  # CIDR block for subnet in first AZ
  public_subnet_cidr_b = var.public_subnet_cidr_b
  private_subnet_cidr  = var.private_subnet_cidr   # Example CIDR block
}

module "ec2" {
  source             = "./ec2"
  alb_sg_id          = module.vpc.alb_sg_id
  ec2_sg_id          = module.vpc.ec2_sg_id
  ec2_sg_bastion_id  = module.vpc.ec2_sg_bastion_id
  public_subnet_id_a = module.vpc.public_subnet_id_a
  public_subnet_id_b = module.vpc.public_subnet_id_b
  private_subnet_id  = module.vpc.private_subnet_id
  vpc_id             = module.vpc.vpc_id
  instance_type      = var.instance_type
  ami_id             = var.ami_id
  github_pat         = var.github_pat
}


