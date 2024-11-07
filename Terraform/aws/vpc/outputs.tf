output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}

output "public_subnet_id_a" {
  value = aws_subnet.public_a.id
}

output "public_subnet_id_b" {
  value = aws_subnet.public_b.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}
