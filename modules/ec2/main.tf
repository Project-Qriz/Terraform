# 로컬 변수 정의
locals {
  # 단일 서브넷 ID가 제공된 경우와 여러 서브넷 ID가 제공된 경우를 처리
  subnet_ids = length(var.private_subnet_ids) > 0 ? var.private_subnet_ids : [var.private_subnet_id]
  # ASG 사용 여부 결정 (명시적으로 설정되거나 운영 환경인 경우)
  use_asg = var.use_asg || var.environment == "prod"
}

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
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 5001
    to_port         = 5001
    protocol        = "tcp"
    security_groups = [var.spring_security_group_id, var.alb_security_group_id]
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
  # ASG를 사용하지 않는 경우에만 생성
  count = local.use_asg ? 0 : 1

  ami           = var.ami_id
  instance_type = var.spring_instance_type
  subnet_id     = var.private_subnet_id

  vpc_security_group_ids = [aws_security_group.spring_sg.id, var.ec2_rds_security_group_id]
  key_name = var.key_name

  user_data = var.spring_user_data

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name        = "${var.environment}-spring"
    Environment = var.environment
  }
}

resource "aws_instance" "flask" {
  # ASG를 사용하지 않는 경우에만 생성
  count = local.use_asg ? 0 : 1

  ami           = var.ami_id
  instance_type = var.flask_instance_type
  subnet_id     = var.private_subnet_id

  vpc_security_group_ids = [aws_security_group.flask_sg.id, var.ec2_rds_security_group_id]
  key_name = var.key_name
  user_data = var.flask_user_data

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

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
  count = local.use_asg ? 1 : 0

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

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-spring-instance"
    }
  }
}

# Auto Scaling Group for Spring Application
resource "aws_autoscaling_group" "spring_asg" {
  count = local.use_asg ? 1 : 0

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
  count = local.use_asg ? 1 : 0

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

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20  # 16GB
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-flask-instance"
    }
  }
}

# Auto Scaling Group for Flask Application
resource "aws_autoscaling_group" "flask_asg" {
  count = local.use_asg ? 1 : 0

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
  count = local.use_asg ? 1 : 0

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
  count = local.use_asg ? 1 : 0

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

### ECR 접근을 위한 EC2 IAM Role ###
# IAM 역할 생성
resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-ec2-role"
    Environment = var.environment
  }
}

# ECR 접근 정책 생성
resource "aws_iam_policy" "ecr_policy" {
  name        = "${var.environment}-ecr-policy"
  description = "Policy for ECR access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# 역할에 정책 연결
resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

# EC2 인스턴스 프로필 생성
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# S3 접근 정책 추가
resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.environment}-s3-access-policy"
  description = "Policy for S3 access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::qriz-model-data",
          "arn:aws:s3:::qriz-model-data/*",
          "arn:aws:s3:::qriz-data-storage",
          "arn:aws:s3:::qriz-data-storage/*",
          "arn:aws:s3:::qriz-training-logs",
          "arn:aws:s3:::qriz-training-logs/*"
        ]
      }
    ]
  })
}

# S3 정책을 EC2 역할에 연결
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# CloudWatch 로그 액세스 권한 추가 (모델 학습용)
resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "${var.environment}-cloudwatch-policy"
  description = "Policy for CloudWatch access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      }
    ]
  })
}

# CloudWatch 정책을 EC2 역할에 연결
resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}