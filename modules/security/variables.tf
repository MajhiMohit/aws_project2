variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where security groups will be provisioned"
}

variable "environment" {
  type        = string
  description = "Deployment environment (Dev/Test/Prod)"
  default     = "Dev"
}

variable "team" {
  type        = string
  description = "Team identifier (T193 Security Core)"
  default     = "T193"
}

variable "admin_ssh_cidr" {
  type        = string
  description = "Restricted CIDR block allowed for SSH access (Security Guardrail)"
  default     = "203.0.113.50/32" # Sample restricted IP range instead of 0.0.0.0/0
}
