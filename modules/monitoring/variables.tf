variable "environment" {
  type        = string
  description = "Deployment environment (Dev/Test/Prod)"
  default     = "Dev"
}

variable "team" {
  type        = string
  description = "Team responsible for monitoring (T334)"
  default     = "T334"
}

variable "alert_email" {
  type        = string
  description = "Email address to receive CloudWatch security alarm notifications"
  default     = ""
}
