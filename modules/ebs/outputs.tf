output "volume_ids" {
  description = "Lista de IDs dos volumes EBS"
  value       = aws_ebs_volume.this[*].id
}