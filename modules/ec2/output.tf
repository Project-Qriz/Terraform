# output "spring_instance_id" {
#   value = aws_instance.spring.id
# }

# output "flask_instance_id" {
#   value = aws_instance.flask.id
# }

# output "spring_security_group_id" {
#   value = aws_security_group.spring_sg.id
# }

# output "flask_security_group_id" {
#   value = aws_security_group.flask_sg.id
# }

output "spring_instance_id" {
  value = var.use_asg ? null : aws_instance.spring_instance[0].id
}

output "flask_instance_id" {
  value = var.use_asg ? null : aws_instance.flask_instance[0].id
}

output "spring_target_group_arns" {
  value = var.use_asg ? [aws_lb_target_group.spring_tg[0].arn] : null
}

output "flask_target_group_arns" {
  value = var.use_asg ? [aws_lb_target_group.flask_tg[0].arn] : null
}

output "spring_security_group_id" {
  value = aws_security_group.spring_sg.id
}

output "flask_security_group_id" {
  value = aws_security_group.flask_sg.id
}