# modules/bastion/outputs.tf
output "bastion_instance_id" {
  description = "ID of bastion instance"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP of bastion instance"
  value       = aws_instance.bastion.public_ip
}

output "bastion_security_group_id" {
  description = "Security group ID of bastion instance"
  value       = aws_security_group.bastion.id
}