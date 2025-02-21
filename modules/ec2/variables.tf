variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID"
  type        = string
}

variable "alb_security_group_id" {
  description = "ALB security group ID"
  type        = string
}

# variable "bastion_security_group_id" {
#   description = "Bastion security group ID"
#   type        = string
# }

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0fa42ed59eb46290d"
}

variable "key_name" {
  description = "Key name for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "spring_user_data" {
  description = "User data script"
  type        = string
  default     = <<-EOF
              #!/bin/bash
              # System update
              dnf update -y
              
              # Install basic tools
              dnf install -y git
              dnf install -y wget
              dnf install -y vim
              dnf install -y htop
              
              # Install Java 11
              dnf install -y java-17-amazon-corretto
              
              # Install and configure Docker
              dnf install -y docker
              systemctl enable docker
              systemctl start docker
              usermod -a -G docker ec2-user
              EOF
}

variable "flask_user_data" {
  description = "User data script"
  type        = string
  default     = <<-EOF
              #!/bin/bash
              # System update
              dnf update -y

              # Install Python tools
              dnf install -y python3-pip
              dnf install -y python3-devel
              
              # Install and configure Docker
              dnf install -y docker
              systemctl enable docker
              systemctl start docker
              usermod -a -G docker ec2-user
              EOF
}