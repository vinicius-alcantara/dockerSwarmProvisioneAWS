output "instance_id" {
  value = aws_instance.this[*].id
}

output "instance_public_ip" {
  value = aws_eip.eip_instances[*].public_ip
}

output "instance_private_ip" {
  value = aws_instance.this[*].private_ip
}

