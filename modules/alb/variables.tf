variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "spring_instance_id" {
  description = "Spring EC2 instance ID"
  type        = string
}

variable "flask_instance_id" {
  description = "Flask EC2 instance ID"
  type        = string
}

### Prod ###
variable "spring_target_group_arns" {
  type = list(string)
  description = "ARNs of the Spring target groups"
  default = []
}

variable "flask_target_group_arns" {
  type = list(string)
  description = "ARNs of the Flask target groups"
  default = []
}