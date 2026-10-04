variable "cloudtrail_bucket_name" {
  type        = string
  description = "Globally unique name for the CloudTrail S3 logging bucket"
}

variable "environment" {
  type        = string
  description = "Deployment environment (Dev/Test/Prod)"
  default     = "Dev"
}

variable "team" {
  type        = string
  description = "Team identifier responsible for logging module (T334)"
  default     = "T334"
}
