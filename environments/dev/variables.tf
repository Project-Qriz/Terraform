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

# S3 로그 보존 기간 변수
variable "log_retention_days" {
  description = "Number of days to retain training logs in S3"
  type        = number
  default     = 30
}

# Transit Gateway 관련 변수
variable "enable_tgw" {
  description = "Enable Transit Gateway"
  type        = bool
  default     = true
}

variable "tgw_destination_cidr" {
  description = "CIDR block for the destination network to route through Transit Gateway"
  type        = string
  default     = "10.0.0.0/8" # 다른 VPC들의 CIDR 범위를 포함하는 값
}