output "config_recorder_id" {
  value       = aws_config_configuration_recorder.main.id
  description = "ID of the AWS Config configuration recorder"
}

output "config_bucket_name" {
  value       = aws_s3_bucket.config_bucket.id
  description = "Name of the S3 bucket storing AWS Config snapshots"
}

output "config_role_arn" {
  value       = aws_iam_role.config_role.arn
  description = "ARN of the IAM role used by AWS Config"
}

output "s3_encryption_rule_arn" {
  value       = aws_config_config_rule.s3_encryption.arn
  description = "ARN of the S3 encryption compliance rule"
}

output "cloudtrail_enabled_rule_arn" {
  value       = aws_config_config_rule.cloudtrail_enabled.arn
  description = "ARN of the CloudTrail enabled compliance rule"
}
