variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC for security group rules"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet where NAT instance will be placed"
  type        = string
}

variable "nat_ami_id" {
  description = "AMI ID for NAT instance"
  type        = string
  default     = "ami-0fa42ed59eb46290d" 
}

variable "instance_type" {
  description = "Instance type for NAT instance"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key name for NAT instance"
  type        = string
}