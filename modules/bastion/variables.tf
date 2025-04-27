# modules/bastion/variables.tf
variable "environment" {
  description = "Environment (dev, prod, etc)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for bastion host"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID"
  type        = string
  default     = "ami-0fa42ed59eb46290d"
}

# 인스턴스 프로필 변수 추가
variable "instance_profile_name" {
  description = "IAM Instance Profile Name for S3 access"
  type        = string
  default     = ""
}