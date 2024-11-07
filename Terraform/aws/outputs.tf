output "alb_dns" {
  value = module.ec2.front_end_alb_dns  # Assuming you define `output "front_end_alb_dns"` in your `ec2` module
}

output "ec2_instance_id" {
  value = module.ec2.front_end_instance_id  # Assuming you define `output "front_end_instance_id"` in `ec2` module
}
