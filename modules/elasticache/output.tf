output "elasticache_endpoint" {
  description = "Elasticache endpoint"
  value       = aws_elasticache_cluster.redis.cache_nodes.0.address
}

output "elasticache_port" {
  description = "Elasticache port"
  value       = aws_elasticache_cluster.redis.cache_nodes.0.port
}

output "elasticache_security_group_id" {
  description = "Elasticache security group ID"
  value       = aws_security_group.elasticache_sg.id
}