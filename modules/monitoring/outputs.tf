output "sns_topic_arn" {
  value       = aws_sns_topic.security_alerts.arn
  description = "ARN of the SNS topic receiving CloudWatch security alerts"
}

output "sns_topic_name" {
  value       = aws_sns_topic.security_alerts.name
  description = "Name of the SNS security alerts topic"
}

output "root_login_alarm_name" {
  value       = aws_cloudwatch_metric_alarm.root_login_alarm.alarm_name
  description = "Name of the root account login CloudWatch alarm"
}

output "unauthorized_api_alarm_name" {
  value       = aws_cloudwatch_metric_alarm.unauthorized_api_alarm.alarm_name
  description = "Name of the unauthorized API calls CloudWatch alarm"
}

output "cloudtrail_tamper_alarm_name" {
  value       = aws_cloudwatch_metric_alarm.cloudtrail_tamper_alarm.alarm_name
  description = "Name of the CloudTrail tampering CloudWatch alarm"
}
