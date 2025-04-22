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
    from_port = 443
    to_port = 443
    protocol = "tcp"
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

resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal          = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.alb_sg.id]
  subnets           = var.public_subnet_ids

  tags = {
    Name        = "${var.environment}-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "spring" {
  # 타겟 그룹은 항상 생성하되, ASG에서 제공하는 타겟 그룹이 있으면 사용하지 않음
  count = 1

  name        = "${var.environment}-spring-tg-alb"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path = "/api/v1/health"
  }
}

resource "aws_lb_target_group" "flask" {
  # 타겟 그룹은 항상 생성하되, ASG에서 제공하는 타겟 그룹이 있으면 사용하지 않음
  count = 1

  name        = "${var.environment}-flask-tg-alb"
  port        = 5001
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path = "/health"
  }
}

resource "aws_lb_target_group_attachment" "spring" {
  # var.spring_instance_id가 null이 아니고 빈 문자열도 아닐 때만 생성
  count = var.spring_instance_id != null && var.spring_instance_id != "" ? 1 : 0

  target_group_arn = aws_lb_target_group.spring[0].arn  # 인덱스 없음
  target_id        = var.spring_instance_id
  port             = 8081
}

resource "aws_lb_target_group_attachment" "flask" {
  # var.flask_instance_id가 null이 아니고 빈 문자열도 아닐 때만 생성
  count = var.flask_instance_id != null && var.flask_instance_id != "" ? 1 : 0

  target_group_arn = aws_lb_target_group.flask[0].arn  # 인덱스 없음
  target_id        = var.flask_instance_id
  port             = 5001
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    # ASG 타겟 그룹이 있으면 사용, 없으면 기본 타겟 그룹 사용
    target_group_arn = length(var.spring_target_group_arns) > 0 ? var.spring_target_group_arns[0] : aws_lb_target_group.spring[0].arn
  }
}

### Prod ###

# 리스너 규칙 업데이트
resource "aws_lb_listener_rule" "spring_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  action {
    type = "forward"
    # ASG 타겟 그룹이 있으면 사용, 없으면 기본 타겟 그룹 사용
    target_group_arn = length(var.spring_target_group_arns) > 0 ? var.spring_target_group_arns[0] : aws_lb_target_group.spring[0].arn
  }

  condition {
    path_pattern {
      values = [ "/api/*" ]
    }
  }
}