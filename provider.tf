provider "aws" {
  region = var.aws_region

  # MANDATORY RESOURCE TAGGING GUARDRAIL
  # Automatically applies default tags to ALL AWS resources managed by this project
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "https://github.com/your-org/terraform-aws-landing-zone"
    }
  }
}
