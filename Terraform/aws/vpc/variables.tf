variable "vpc_cidr" {
  default = "192.0.0.0/16"  # Or your desired CIDR block
}

variable "public_subnet_cidr_a" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "192.0.1.0/24"  # Set a default or specify in main.tf
}
variable "public_subnet_cidr_b" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "192.0.3.0/24"  # Set a default or specify in main.tf
}


variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "192.0.2.0/24"  # Set a default or specify in main.tf
}
