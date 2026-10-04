# ------------------------------------------------------------------------------
# IAM MODULE: Role Definitions, Least-Privilege Policies, Instance Profiles
# Managed by: Team T193 (Identity & Governance Core)
# ------------------------------------------------------------------------------

# 1. Developer Role (Assumable role for team members)
resource "aws_iam_role" "developer_role" {
  name = "LandingZone-DevRole-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "LandingZone-DevRole-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}

# 2. SECURITY GUARDRAIL: Least-Privilege Custom Policy
# Allows managing compute/networking, but explicitly DENIES deleting CloudTrail or log buckets
resource "aws_iam_policy" "least_privilege_policy" {
  name        = "LandingZone-DeveloperPolicy-${var.environment}"
  description = "Provides access to standard resources while locking down audit logging"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:RunInstances",
          "ec2:StopInstances",
          "ec2:StartInstances",
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation"
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",
          "s3:DeleteBucket"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach Least-Privilege Policy to Developer Role
resource "aws_iam_role_policy_attachment" "dev_policy_attach" {
  role       = aws_iam_role.developer_role.name
  policy_arn = aws_iam_policy.least_privilege_policy.arn
}

# 3. Instance Profile for EC2 Systems Manager (SSM) management
resource "aws_iam_instance_profile" "dev_instance_profile" {
  name = "LandingZone-DevInstanceProfile-${var.environment}"
  role = aws_iam_role.developer_role.name
}
