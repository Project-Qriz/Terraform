output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

# Transit Gateway 관련 출력 추가
output "transit_gateway_id" {
  description = "ID of the Transit Gateway (if enabled)"
  value       = var.enable_tgw ? aws_ec2_transit_gateway.tgw[0].id : null
}

output "transit_gateway_attachment_id" {
  description = "ID of the Transit Gateway VPC attachment (if enabled)"
  value       = var.enable_tgw ? aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[0].id : null
}