variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Elasticache subnet group"
  type        = list(string)
}

variable "app_security_group_ids" {
  description = "Security group IDs that need access to Elasticache"
  type        = list(string)
}

variable "node_type" {
  description = "Elasticache node type"
  type        = string
  default     = "cache.t4g.micro"  # 가장 저렴한 옵션
}

variable "snapshot_retention_days" {
  description = "Number of days to retain Redis snapshots"
  type        = number
  default     = 1  # 비용 최소화
}