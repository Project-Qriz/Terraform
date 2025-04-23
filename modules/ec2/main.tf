resource "aws_security_group" "spring_sg" {
  name        = "${var.environment}-spring-sg"
  description = "Security group for spring"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8081
    to_port         = 8081
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
    Name        = "${var.environment}-spring-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "flask_sg" {
  name        = "${var.environment}-flask-sg"
  description = "Security group for flask"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_security_group_id]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 5001
    to_port         = 5001
    protocol        = "tcp"
    security_groups = [var.spring_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-flask-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "spring" {
  # ASG를 사용하지 않고 private_subnet_id가 제공된 경우에만 인스턴스 생성
  count = var.use_asg || var.private_subnet_id == "" ? 0 : 1

  ami           = var.ami_id
  instance_type = var.spring_instance_type
  subnet_id     = var.private_subnet_id

  vpc_security_group_ids = [aws_security_group.spring_sg.id, var.ec2_rds_security_group_id]
  key_name = var.key_name

  user_data = var.spring_user_data

  tags = {
    Name        = "${var.environment}-spring"
    Environment = var.environment
  }
}

resource "aws_instance" "flask" {
  # ASG를 사용하지 않고 private_subnet_id가 제공된 경우에만 인스턴스 생성
  count = var.use_asg || var.private_subnet_id == "" ? 0 : 1

  ami           = var.ami_id
  instance_type = var.flask_instance_type
  subnet_id     = var.private_subnet_id

  vpc_security_group_ids = [aws_security_group.flask_sg.id, var.ec2_rds_security_group_id]
  key_name = var.key_name
  user_data = var.flask_user_data

  root_block_device {
    volume_size = 100
  }

  tags = {
    Name        = "${var.environment}-flask"
    Environment = var.environment
  }
}

### Prod ###

# Launch Template for Spring Application
resource "aws_launch_template" "spring_template" {
  count = var.use_asg ? 1 : 0

  name_prefix = "${var.environment}-spring-"
  instance_type = var.spring_instance_type
  image_id = var.ami_id

  vpc_security_group_ids = [
    aws_security_group.spring_sg.id,
    var.ec2_rds_security_group_id
  ]

  key_name = var.key_name
  user_data = base64encode(var.spring_user_data)

  update_default_version = true

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-spring-instance"
    }
  }
}

# Auto Scaling Group for Spring Application
resource "aws_autoscaling_group" "spring_asg" {
  count = var.use_asg ? 1 : 0

  name = "${var.environment}-spring-asg"
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id = aws_launch_template.spring_template[0].id
    version = "$Default"
  }

  target_group_arns = [ aws_lb_target_group.spring_tg[0].arn ]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = "${var.environment}-spring-instance"
    propagate_at_launch = true
  }
}

# Launch Template for Flask Application
resource "aws_launch_template" "flask_template" {
  count = var.use_asg ? 1 : 0

  name_prefix = "${var.environment}-flask-"
  instance_type = var.flask_instance_type
  image_id = var.ami_id

  vpc_security_group_ids = [
    aws_security_group.flask_sg.id,
    var.ec2_rds_security_group_id
  ]

  key_name = var.key_name
  user_data = base64encode(var.flask_user_data)

  update_default_version = true

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-flask-instance"
    }
  }
}

# Auto Scaling Group for Flask Application
resource "aws_autoscaling_group" "flask_asg" {
  count = var.use_asg ? 1 : 0

  name = "${var.environment}-flask-asg"
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id = aws_launch_template.flask_template[0].id
    version = "$Default"
  }

  target_group_arns = [ aws_lb_target_group.flask_tg[0].arn ]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = "${var.environment}-flask-instance"
    propagate_at_launch = true
  }
}

# Target Groups for ALB
resource "aws_lb_target_group" "spring_tg" {
  count = var.use_asg ? 1 : 0

  name = "${var.environment}-spring-tg-ec2"
  port = 8081
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    path = "/api/health"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "flask_tg" {
  count = var.use_asg ? 1 : 0

  name = "${var.environment}-flask-tg-ec2"
  port = 5001
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    path = "/health"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}