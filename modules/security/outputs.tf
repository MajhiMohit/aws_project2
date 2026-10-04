output "web_app_security_group_id" {
  value       = aws_security_group.web_app_sg.id
  description = "Security Group ID for Web/App instances"
}

output "database_security_group_id" {
  value       = aws_security_group.database_sg.id
  description = "Security Group ID for Database instances"
}
