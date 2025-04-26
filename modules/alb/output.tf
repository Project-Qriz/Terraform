output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}

output "spring_target_group_arn" {
  value = aws_lb_target_group.spring.arn
}

output "flask_target_group_arn" {
  value = aws_lb_target_group.flask.arn
}