output "developer_role_arn" {
  value       = aws_iam_role.developer_role.arn
  description = "ARN of the provisioned developer role"
}

output "developer_role_name" {
  value       = aws_iam_role.developer_role.name
  description = "Name of the provisioned developer role"
}

output "instance_profile_name" {
  value       = aws_iam_instance_profile.dev_instance_profile.name
  description = "Name of the provisioned IAM Instance Profile"
}
