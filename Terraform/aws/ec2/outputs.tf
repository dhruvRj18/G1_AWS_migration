output "front_end_alb_dns" {
  value = aws_lb.front_end_alb.dns_name
}

output "front_end_instance_id" {
  value = aws_instance.front_end.id
}
