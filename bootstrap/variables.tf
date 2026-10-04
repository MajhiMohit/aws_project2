variable "aws_region" {
  type        = string
  description = "AWS region for provisioning backend state resources"
  default     = "us-east-1"
}

variable "state_bucket_name" {
  type        = string
  description = "Globally unique name for the S3 bucket storing Terraform remote state"
  default     = "t-landingzone-tfstate-bucket-unique"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Name of the DynamoDB table used for Terraform state locking"
  default     = "t-landingzone-tfstate-locks"
}

variable "environment" {
  type        = string
  description = "Target deployment environment (Dev/Test/Prod)"
  default     = "Dev"
}
