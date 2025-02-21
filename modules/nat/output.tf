output "nat_instance_id" {
  description = "ID of the NAT instance"
  value       = aws_instance.main.id
}

output "nat_instance_eni_id" {
  description = "ID of the NAT instance's primary network interface"
  value       = aws_instance.main.primary_network_interface_id
}

output "nat_security_group_id" {
  description = "ID of the NAT security group"
  value       = aws_security_group.main.id
}