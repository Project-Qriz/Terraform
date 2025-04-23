variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "key_name" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_username" {
  type = string
}

variable "database_password" {
  type = string
}

variable "asg_min_size" {
  type = number
  description = "Minimum size of the auto scaling group"
}

variable "asg_max_size" {
  type = number
  description = "Maximum size of the auto scaling group"
}

variable "asg_desired_capacity" {
  type = number
  description = "Desired capacity of the auto scaling group"
}

variable "use_asg" {
  type = bool
  description = "Whether to use Auto Scaling Group"
  default     = true
}

### Elasticache ###
variable "elasticache_node_type" {
  description = "Elasticache node type"
  type        = string
  default     = "cache.t4g.micro"
}

variable "elasticache_snapshot_retention_days" {
  description = "Number of days to retain Redis snapshots"
  type        = number
  default     = 1
}