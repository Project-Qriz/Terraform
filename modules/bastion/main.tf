# modules/bastion/main.tf
resource "aws_security_group" "bastion" {
  name        = "${var.environment}-bastion-sg"
  description = "Security group for Bastion/Jenkins instance"
  vpc_id      = var.vpc_id

  # SSH 접근
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 실제 운영환경에서는 회사 IP로 제한하는 것을 권장
  }

  # Jenkins 웹 접근
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 실제 운영환경에서는 회사 IP로 제한하는 것을 권장
  }

  # 외부 통신
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-bastion-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = "t3.medium"  # Jenkins 때문에 리소스 증설
  subnet_id     = var.public_subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.bastion.id]

  user_data = <<-EOF
              #!/bin/bash
              # System update
              dnf update -y
              
              # Install basic tools
              dnf install -y git
              dnf install -y wget
              dnf install -y vim
              dnf install -y htop
              
              # Install Java 21 (Jenkins requirement)
              dnf install -y java-21-amazon-corretto
              
              # Install Jenkins
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              dnf install -y jenkins
              
              # Start Jenkins
              systemctl enable jenkins
              systemctl start jenkins
              
              # Install Docker
              dnf install -y docker
              systemctl enable docker
              systemctl start docker
              usermod -a -G docker ec2-user
              usermod -a -G docker jenkins
              
              # Install Docker Compose
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              
              # Install AWS CLI
              dnf install -y aws-cli
              
              # Configure Jenkins user for SSH
              mkdir -p /var/lib/jenkins/.ssh
              chown -R jenkins:jenkins /var/lib/jenkins/.ssh
              chmod 700 /var/lib/jenkins/.ssh
              EOF

  root_block_device {
    volume_size = 30  # Jenkins를 위한 충분한 디스크 공간
  }

  tags = {
    Name        = "${var.environment}-bastion"
    Environment = var.environment
  }
}