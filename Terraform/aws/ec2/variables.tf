variable "alb_sg_id" {}
variable "ec2_sg_id" {}
variable "ec2_sg_bastion_id" {}
variable "public_subnet_id_a" {}
variable "public_subnet_id_b" {}
variable "private_subnet_id" {}
variable "vpc_id" {}
variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
}
variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}
