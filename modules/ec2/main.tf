resource "aws_security_group" "app_sg" {
  name        = "${var.environment}-app-sg"
  description = "Security group for application"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    # security_groups = [var.bastion_security_group_id]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-app-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "spring" {
  ami           = var.ami_id
  instance_type = var.instance_type
  # subnet_id     = var.private_subnet_id
  subnet_id     = var.public_subnet_id

  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name = var.key_name

  user_data = var.spring_user_data

  tags = {
    Name        = "${var.environment}-spring"
    Environment = var.environment
  }
}

resource "aws_instance" "flask" {
  ami           = var.ami_id
  instance_type = var.instance_type
  # subnet_id     = var.private_subnet_id
  subnet_id     = var.public_subnet_id

  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name = var.key_name
  user_data = var.flask_user_data

  tags = {
    Name        = "${var.environment}-flask"
    Environment = var.environment
  }
}