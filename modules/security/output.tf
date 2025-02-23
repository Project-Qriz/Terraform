output "rds_ec2_security_group_id" {
  value = aws_security_group.rds_ec2.id
}

output "ec2_rds_security_group_id" {
  value = aws_security_group.ec2_rds.id
}