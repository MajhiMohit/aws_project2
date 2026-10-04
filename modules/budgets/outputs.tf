output "monthly_budget_id" {
  value       = aws_budgets_budget.monthly_cost.id
  description = "ID of the monthly overall cost budget"
}

output "monthly_budget_limit" {
  value       = aws_budgets_budget.monthly_cost.limit_amount
  description = "Monthly budget limit in USD"
}

output "ec2_budget_id" {
  value       = aws_budgets_budget.ec2_budget.id
  description = "ID of the EC2-specific monthly budget"
}
