variable "environment" {
  type        = string
  description = "Deployment environment (Dev/Test/Prod)"
  default     = "Dev"
}

variable "team" {
  type        = string
  description = "Team responsible for compliance (T193)"
  default     = "T193"
}

variable "config_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for AWS Config snapshots"
}
