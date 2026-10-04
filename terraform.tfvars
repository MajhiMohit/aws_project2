# ==============================================================================
# TERRAFORM VARIABLE VALUES — Landing Zone Environment Configuration
# ==============================================================================

aws_region             = "ap-south-1"
environment            = "Dev"
project_name           = "Terraform-AWS-Landing-Zone"

# VPC & Networking (Team T052)
vpc_cidr               = "10.0.0.0/16"
public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs   = ["10.0.10.0/24", "10.0.20.0/24"]
availability_zones     = ["ap-south-1a", "ap-south-1b"]

# Logging (Team T334)
cloudtrail_bucket_name = "t-landingzone-audit-logs-team-collaboration-052-193-334"

# Security (Team T193)
admin_ssh_cidr         = "198.51.100.25/32"

# Monitoring (Team T334)
alert_email            = "team-lead@example.com"

# AWS Config (Team T193)
config_bucket_name     = "t-landingzone-config-snapshots-052-193-334"

# Budgets (Team T334)
monthly_budget_limit   = "50"
ec2_budget_limit       = "20"
budget_alert_emails    = ["team-lead@example.com"]
