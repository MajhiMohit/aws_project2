# ==============================================================================
# ROOT VARIABLES — Terraform-Managed AWS Landing Zone
# ==============================================================================

variable "aws_region" {
  type        = string
  description = "Target AWS region for deploying the Landing Zone infrastructure"
  default     = "ap-south-1"
}

variable "environment" {
  type        = string
  description = "Target deployment environment (Dev/Test/Prod)"
  default     = "Dev"
}

variable "project_name" {
  type        = string
  description = "Name of the project for mandatory resource tagging"
  default     = "Terraform-AWS-Landing-Zone"
}

# --- VPC Variables -----------------------------------------------------------

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the Landing Zone VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of public subnet CIDR ranges"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of private subnet CIDR ranges"
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "Target AWS Availability Zones"
  default     = ["ap-south-1a", "ap-south-1b"]
}

# --- Logging Variables -------------------------------------------------------

variable "cloudtrail_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for CloudTrail audit logging"
  default     = "t-landingzone-cloudtrail-logs-unique-dev"
}

# --- Security Variables ------------------------------------------------------

variable "admin_ssh_cidr" {
  type        = string
  description = "Restricted Admin IP block for SSH access (Security Guardrail)"
  default     = "203.0.113.50/32"
}

# --- Monitoring Variables ----------------------------------------------------

variable "alert_email" {
  type        = string
  description = "Email address for CloudWatch security alarm notifications"
  default     = ""
}

# --- AWS Config Variables ----------------------------------------------------

variable "config_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for AWS Config snapshots"
  default     = "t-landingzone-config-snapshots-unique-dev"
}

# --- Budget Variables --------------------------------------------------------

variable "monthly_budget_limit" {
  type        = string
  description = "Maximum monthly total AWS spend in USD"
  default     = "50"
}

variable "ec2_budget_limit" {
  type        = string
  description = "Maximum monthly EC2 spend in USD"
  default     = "20"
}

variable "budget_alert_emails" {
  type        = list(string)
  description = "Email addresses to receive budget overspend alerts"
  default     = ["team-lead@example.com"]
}
