# ==============================================================================
# ROOT OUTPUTS — Terraform-Managed AWS Landing Zone
# ==============================================================================


output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the primary Landing Zone VPC"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "IDs of the public subnets provisioned by Team T052"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "IDs of the private subnets provisioned by Team T052"
}

output "nat_gateway_id" {
  value       = module.vpc.nat_gateway_id
  description = "ID of the NAT Gateway (Team T052)"
}

output "nat_gateway_public_ip" {
  value       = module.vpc.nat_gateway_public_ip
  description = "Public IP of the NAT Gateway — private subnet outbound traffic exits here"
}

output "vpc_flow_log_id" {
  value       = module.vpc.flow_log_id
  description = "ID of the VPC Flow Log resource (network traffic audit)"
}

output "flow_log_cloudwatch_group" {
  value       = module.vpc.flow_log_cloudwatch_group
  description = "CloudWatch Log Group storing VPC Flow Logs"
}



output "cloudtrail_bucket_name" {
  value       = module.logging.cloudtrail_bucket_id
  description = "S3 bucket name storing CloudTrail audit logs (Team T334)"
}

output "cloudtrail_arn" {
  value       = module.logging.cloudtrail_arn
  description = "ARN of the active CloudTrail audit trail"
}



output "web_app_security_group_id" {
  value       = module.security.web_app_security_group_id
  description = "Security Group ID for Web/App instances (Team T193)"
}

output "database_security_group_id" {
  value       = module.security.database_security_group_id
  description = "Security Group ID for Database instances (Team T193)"
}



output "developer_role_arn" {
  value       = module.iam.developer_role_arn
  description = "ARN of the standard developer IAM role (Team T193)"
}



output "sns_security_alerts_arn" {
  value       = module.monitoring.sns_topic_arn
  description = "ARN of the SNS topic that receives CloudWatch security alarms"
}

output "root_login_alarm" {
  value       = module.monitoring.root_login_alarm_name
  description = "Name of the CloudWatch alarm for root account login detection"
}

output "cloudtrail_tamper_alarm" {
  value       = module.monitoring.cloudtrail_tamper_alarm_name
  description = "Name of the CloudWatch alarm for CloudTrail tampering detection"
}



output "config_recorder_id" {
  value       = module.config.config_recorder_id
  description = "ID of the AWS Config recorder"
}

output "config_bucket_name" {
  value       = module.config.config_bucket_name
  description = "S3 bucket storing AWS Config compliance snapshots"
}



output "monthly_budget_id" {
  value       = module.budgets.monthly_budget_id
  description = "ID of the monthly cost budget"
}

output "monthly_budget_limit_usd" {
  value       = module.budgets.monthly_budget_limit
  description = "Monthly budget ceiling in USD"
}
