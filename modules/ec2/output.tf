output "spring_instance_id" {
  value = aws_instance.spring.id
}

output "flask_instance_id" {
  value = aws_instance.flask.id
}

output "app_security_group_id" {
  value = aws_security_group.app_sg.id
}