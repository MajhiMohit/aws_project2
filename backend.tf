# ------------------------------------------------------------------------------
# REMOTE STATE S3 BACKEND WITH DYNAMODB STATE LOCKING
# ------------------------------------------------------------------------------
# Steps to enable:
# 1. Run `terraform apply` in the `bootstrap/` folder to create the S3 bucket & DynamoDB table.
# 2. Update the bucket name below with your unique bucket name.
# 3. Uncomment the backend block below.
# 4. Run `terraform init` to migrate your state to AWS S3!
# ------------------------------------------------------------------------------

# terraform {
#   backend "s3" {
#     bucket         = "t-landingzone-tfstate-bucket-unique"
#     key            = "landing-zone/dev/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "t-landingzone-tfstate-locks"
#     encrypt        = true
#   }
# }
