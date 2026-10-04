# ------------------------------------------------------------------------------
# LOGGING MODULE: CloudTrail Audit Logging & Secure S3 Log Bucket
# Managed by: Team T334 (Logging & Auditing Specialist)
# ------------------------------------------------------------------------------

# Fetch current AWS Account ID dynamically
data "aws_caller_identity" "current" {}

# 1. Centralized S3 Bucket for Storing CloudTrail Audit Logs
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket        = var.cloudtrail_bucket_name
  force_destroy = true

  tags = {
    Name        = var.cloudtrail_bucket_name
    Team        = var.team
    Environment = var.environment
    Purpose     = "Audit-Logging"
  }
}

# Enable AES256 Default Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_bucket_crypto" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Guardrail: Enforce Strict Public Access Block on Log Bucket
resource "aws_s3_bucket_public_access_block" "cloudtrail_bucket_pab" {
  bucket                  = aws_s3_bucket.cloudtrail_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. Bucket Policy granting AWS CloudTrail permission to write logs
resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_bucket.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_bucket.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# 3. AWS CloudTrail Instance for Landing Zone Security Auditing
resource "aws_cloudtrail" "main_trail" {
  name                          = "landing-zone-cloudtrail-${var.environment}"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true

  depends_on = [aws_s3_bucket_policy.cloudtrail_bucket_policy]

  tags = {
    Name        = "landing-zone-cloudtrail-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}
