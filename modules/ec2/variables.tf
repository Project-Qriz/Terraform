variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID"
  type        = string
  default = ""  # Optional
}

variable "alb_security_group_id" {
  description = "ALB security group ID"
  type        = string
}

variable "spring_security_group_id" {
  description = "Spring security group ID"
  type        = string
}

variable "flask_security_group_id" {
  description = "Flask security group ID"
  type        = string
}

variable "bastion_security_group_id" {
  description = "Bastion security group ID"
  type        = string
}

variable "ec2_rds_security_group_id" {
  description = "EC2 RDS security group ID"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0fa42ed59eb46290d"
}

variable "key_name" {
  description = "Key name for EC2 instances"
  type        = string
}

variable "spring_instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.small"
}

variable "flask_instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

# variable "spring_user_data" {
#   description = "User data script"
#   type        = string
#   default     = <<-EOF
#               #!/bin/bash
#               # System update
#               dnf update -y
              
#               # Install basic tools
#               dnf install -y git
#               dnf install -y wget
#               dnf install -y vim
#               dnf install -y htop
              
#               # Install Java 11
#               dnf install -y java-11-amazon-corretto
              
#               # Install and configure Docker
#               dnf install -y docker
#               systemctl enable docker
#               systemctl start docker
#               usermod -a -G docker ec2-user

#               # Install docker compose
#               sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#               sudo chmod +x /usr/local/bin/docker-compose

#               EOF
# }

# variable "flask_user_data" {
#   description = "User data script"
#   type        = string
#   default     = <<-EOF
#               #!/bin/bash
#               # System update
#               dnf update -y

#               # Install Python tools
#               dnf install -y python3-pip
#               dnf install -y python3-devel
              
#               # Install and configure Docker
#               dnf install -y docker
#               systemctl enable docker
#               systemctl start docker
#               usermod -a -G docker ec2-user
#               EOF
# }

### Prod ### 

variable "private_subnet_ids" {
  type = list(string)
  description = "IDs of private subnets where instances will be deployed"
  default = []
}

variable "use_asg" {
  type = bool
  description = "Whether to use Auto Scaling Group"
  default = false
}

variable "min_size" {
  type = number
  description = "Minimum size of the auto scaling group"
  default = 1
}

variable "max_size" {
  type = number
  description = "Maximum size of the auto scaling group"
  default = 1
}

variable "desired_capacity" {
  type = number
  description = "Desired capacity of the auto scaling group"
  default = 1
}

variable "spring_user_data" {
  description = "User data script for Spring instances"
  type        = string
  default     = <<-EOF
              #!/bin/bash
              # System update
              dnf update -y
              
              # Install basic tools
              dnf install -y git wget vim htop
              
              # Install Java 11
              dnf install -y java-11-amazon-corretto
              
              # Install and configure Docker
              dnf install -y docker
              systemctl enable docker
              systemctl start docker
              usermod -a -G docker ec2-user

              # Install docker compose
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              
              # ECR 로그인
              aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 314146328505.dkr.ecr.ap-northeast-2.amazonaws.com
              
              # 기존 컨테이너 정리 (있는 경우)
              if docker ps -a | grep -q backend-container; then
                docker stop backend-container
                docker rm backend-container
              fi
              
              # 최신 이미지 가져오기 및 실행
              docker pull 314146328505.dkr.ecr.ap-northeast-2.amazonaws.com/qriz/api:main
              docker run -d --name backend-container -p 8081:8081 314146328505.dkr.ecr.ap-northeast-2.amazonaws.com/qriz/api:main
              EOF
}

variable "flask_user_data" {
  description = "User data script for Flask instances"
  type        = string
  default     = <<-EOF
              #!/bin/bash
              # System update
              dnf update -y

              # Install Python tools
              dnf install -y python3-pip python3-devel
              
              # Install and configure Docker
              dnf install -y docker
              systemctl enable docker
              systemctl start docker
              usermod -a -G docker ec2-user
              
              # ECR 로그인
              aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 314146328505.dkr.ecr.ap-northeast-2.amazonaws.com
              
              # 기존 컨테이너 정리 (있는 경우)
              if docker ps -a | grep -q dkt-container; then
                docker stop dkt-container
                docker rm dkt-container
              fi
              
              # 최신 이미지 가져오기 및 실행
              docker pull 314146328505.dkr.ecr.ap-northeast-2.amazonaws.com/qriz/dkt:main
              docker run -d --name dkt-container -p 5001:5001 314146328505.dkr.ecr.ap-northeast-2.amazonaws.com/qriz/dkt:main
              EOF
}