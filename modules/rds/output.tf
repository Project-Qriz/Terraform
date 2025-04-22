output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

### Prod ###
output "rds_replica_endpoint" {
  value = var.create_replica ? aws_db_instance.replica[0].endpoint : null
}