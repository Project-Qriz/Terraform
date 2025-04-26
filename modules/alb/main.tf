
# ALB 보안 그룹
resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
  }
}

# ALB 메인 리소스
resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name        = "${var.environment}-alb"
    Environment = var.environment
  }
}

# Spring Boot 애플리케이션을 위한 대상 그룹
resource "aws_lb_target_group" "spring" {
  # 환경별로 고유한 이름 사용
  name        = "${var.environment}-spring-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/api/health"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  # 중요: 리소스 교체 시 충돌 방지
  lifecycle {
    create_before_destroy = true
  }
}

# Flask DKT 애플리케이션을 위한 대상 그룹
resource "aws_lb_target_group" "flask" {
  # 환경별로 고유한 이름 사용
  name        = "${var.environment}-flask-tg"
  port        = 5001
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  # 중요: 리소스 교체 시 충돌 방지
  lifecycle {
    create_before_destroy = true
  }
}

# 개발 환경에서만 사용되는 조건부 대상 그룹 연결
resource "aws_lb_target_group_attachment" "spring" {
  # spring_instance_id가 제공된 경우에만 생성 (개발 환경)
  count = var.spring_instance_id != null && var.spring_instance_id != "" ? 1 : 0

  target_group_arn = aws_lb_target_group.spring.arn
  target_id        = var.spring_instance_id
  port             = 8081
}

resource "aws_lb_target_group_attachment" "flask" {
  # flask_instance_id가 제공된 경우에만 생성 (개발 환경)
  count = var.flask_instance_id != null && var.flask_instance_id != "" ? 1 : 0

  target_group_arn = aws_lb_target_group.flask.arn
  target_id        = var.flask_instance_id
  port             = 5001
}

# HTTP 리스너
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    # Spring 대상 그룹을 기본으로 사용
    target_group_arn = length(var.spring_target_group_arns) > 0 ? var.spring_target_group_arns[0] : aws_lb_target_group.spring.arn
  }
}

# Flask 애플리케이션을 위한 리스너 규칙
resource "aws_lb_listener_rule" "flask_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = length(var.flask_target_group_arns) > 0 ? var.flask_target_group_arns[0] : aws_lb_target_group.flask.arn
  }

  condition {
    path_pattern {
      values = ["/predict/*", "/health"]
    }
  }
}