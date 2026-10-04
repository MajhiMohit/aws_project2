# ------------------------------------------------------------------------------
# AWS CONFIG MODULE: Compliance Monitoring & Security Rule Enforcement
# Managed by: Team T193 (Security & Governance)
# Checks: S3 encryption, public bucket blocks, CloudTrail status, root MFA
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# 1. IAM Role for AWS Config Recorder
resource "aws_iam_role" "config_role" {
  name = "LandingZone-ConfigRole-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "config.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "LandingZone-ConfigRole-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}

# Attach AWS managed policy giving Config access to read resources
resource "aws_iam_role_policy_attachment" "config_role_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# 2. S3 Bucket for AWS Config Snapshots
resource "aws_s3_bucket" "config_bucket" {
  bucket        = var.config_bucket_name
  force_destroy = true

  tags = {
    Name        = var.config_bucket_name
    Team        = var.team
    Environment = var.environment
    Purpose     = "AWS-Config-Snapshots"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config_bucket_crypto" {
  bucket = aws_s3_bucket.config_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "config_bucket_pab" {
  bucket                  = aws_s3_bucket.config_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy granting Config write access
resource "aws_s3_bucket_policy" "config_bucket_policy" {
  bucket = aws_s3_bucket.config_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config_bucket.arn
      },
      {
        Sid    = "AWSConfigBucketDelivery"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.config_bucket_pab]
}

# 3. AWS Config Recorder — records resource configuration changes
resource "aws_config_configuration_recorder" "main" {
  name     = "landingzone-config-recorder-${var.environment}"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

# 4. AWS Config Delivery Channel — sends snapshots to S3
resource "aws_config_delivery_channel" "main" {
  name           = "landingzone-config-delivery-${var.environment}"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket

  depends_on = [aws_config_configuration_recorder.main]
}

# Enable the recorder
resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.main]
}

# ==============================================================================
# MANAGED CONFIG RULES — Automated Compliance Checks
# ==============================================================================

# RULE 1: S3 buckets must have server-side encryption enabled
resource "aws_config_config_rule" "s3_encryption" {
  name        = "landingzone-s3-bucket-encrypted-${var.environment}"
  description = "Checks that S3 buckets have default encryption enabled (AES256 or KMS)"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder_status.main]

  tags = {
    Name        = "landingzone-s3-encryption-rule-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}

# RULE 2: S3 buckets must block all public access
resource "aws_config_config_rule" "s3_public_access" {
  name        = "landingzone-s3-no-public-access-${var.environment}"
  description = "Checks that S3 buckets have Block Public Access settings enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_LEVEL_PUBLIC_ACCESS_PROHIBITED"
  }

  depends_on = [aws_config_configuration_recorder_status.main]

  tags = {
    Name        = "landingzone-s3-public-access-rule-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}

# RULE 3: CloudTrail must be enabled in the account
resource "aws_config_config_rule" "cloudtrail_enabled" {
  name        = "landingzone-cloudtrail-enabled-${var.environment}"
  description = "Checks that AWS CloudTrail is enabled and logging"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder_status.main]

  tags = {
    Name        = "landingzone-cloudtrail-enabled-rule-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}

# RULE 4: Root account must have MFA enabled
resource "aws_config_config_rule" "root_mfa" {
  name        = "landingzone-root-mfa-enabled-${var.environment}"
  description = "Checks that Multi-Factor Authentication (MFA) is enabled for the root account"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder_status.main]

  tags = {
    Name        = "landingzone-root-mfa-rule-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}
