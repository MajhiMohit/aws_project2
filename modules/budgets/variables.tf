variable "environment" {
  type        = string
  description = "Deployment environment (Dev/Test/Prod)"
  default     = "Dev"
}

variable "team" {
  type        = string
  description = "Team responsible for budgets (T334)"
  default     = "T334"
}

variable "monthly_budget_limit" {
  type        = string
  description = "Maximum monthly AWS spend in USD before alerts fire"
  default     = "50"
}

variable "ec2_budget_limit" {
  type        = string
  description = "Maximum monthly EC2 spend in USD before alert fires"
  default     = "20"
}

variable "budget_alert_emails" {
  type        = list(string)
  description = "List of email addresses to receive budget overspend alerts"
  default     = ["team-lead@example.com"]
}
