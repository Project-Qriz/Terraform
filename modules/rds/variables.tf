variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "spring_security_group_id" {
  type = string
}

variable "flask_security_group_id" {
  type = string
}

variable "rds_ec2_security_group_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
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