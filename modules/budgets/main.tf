# ------------------------------------------------------------------------------
# AWS BUDGETS MODULE: Cost Management & Overspend Alerts
# Managed by: Team T334 (Governance & FinOps)
# Alerts when monthly spend reaches 80% and 100% of threshold
# ------------------------------------------------------------------------------

# 1. Monthly Cost Budget — alerts when approaching limit
resource "aws_budgets_budget" "monthly_cost" {
  name         = "landingzone-monthly-budget-${var.environment}"
  budget_type  = "COST"
  limit_amount = var.monthly_budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # ALERT 1: 80% of budget consumed (warning)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.budget_alert_emails
  }

  # ALERT 2: 100% of budget consumed (critical)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_alert_emails
  }

  tags = {
    Name        = "landingzone-monthly-budget-${var.environment}"
    Team        = var.team
    Environment = var.environment
    Purpose     = "Cost-Governance"
  }
}

# 2. EC2 Service Budget — monitor compute spend separately
resource "aws_budgets_budget" "ec2_budget" {
  name         = "landingzone-ec2-budget-${var.environment}"
  budget_type  = "COST"
  limit_amount = var.ec2_budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "Service"
    values = ["Amazon Elastic Compute Cloud - Compute"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_alert_emails
  }

  tags = {
    Name        = "landingzone-ec2-budget-${var.environment}"
    Team        = var.team
    Environment = var.environment
    Purpose     = "EC2-Cost-Governance"
  }
}
