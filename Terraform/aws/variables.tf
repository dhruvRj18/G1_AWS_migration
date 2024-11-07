variable "vpc_cidr" {
  default = "192.0.0.0/16"
}

variable "public_subnet_cidr_a" {
  default = "192.0.1.0/24"
}
variable "public_subnet_cidr_b" {
  default = "192.0.3.0/24"
}

variable "private_subnet_cidr" {
  default = "192.0.2.0/24"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = "ami-0984f4b9e98be44bf" # Example Amazon Linux 2 AMI
}


