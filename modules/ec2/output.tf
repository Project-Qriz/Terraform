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
  value = var.use_asg || var.private_subnet_id == "" ? null : aws_instance.spring[0].id
}

output "flask_instance_id" {
  value = var.use_asg || var.private_subnet_id == ""? null : aws_instance.flask[0].id
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

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}