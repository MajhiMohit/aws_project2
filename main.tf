# ==============================================================================
# TERRAFORM-MANAGED AWS LANDING ZONE — MAIN CONFIGURATION
# Teams Involved: T052 (Networking), T193 (Security & IAM), T334 (Logging & Audit)
# Total Students: 12 (4 students per team)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. VPC & NETWORKING MODULE (Managed by Team T052)
#    Provisions: VPC, IGW, Public/Private Subnets, Route Tables,
#                NAT Gateway (private outbound internet), VPC Flow Logs
# ------------------------------------------------------------------------------
module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  environment          = var.environment
  team                 = "T052"
}

# ------------------------------------------------------------------------------
# 2. AUDIT LOGGING & CLOUDTRAIL MODULE (Managed by Team T334)
#    Provisions: S3 bucket (encrypted), bucket policy, AWS CloudTrail
# ------------------------------------------------------------------------------
module "logging" {
  source                 = "./modules/logging"
  cloudtrail_bucket_name = var.cloudtrail_bucket_name
  environment            = var.environment
  team                   = "T334"
}

# ------------------------------------------------------------------------------
# 3. SECURITY GROUPS & GUARDRAILS MODULE (Managed by Team T193)
#    Provisions: Web/App SG, Database SG (restricted port 5432)
# ------------------------------------------------------------------------------
module "security" {
  source         = "./modules/security"
  vpc_id         = module.vpc.vpc_id
  environment    = var.environment
  admin_ssh_cidr = var.admin_ssh_cidr
  team           = "T193"
}

# ------------------------------------------------------------------------------
# 4. IAM & LEAST PRIVILEGE GOVERNANCE MODULE (Managed by Team T193)
#    Provisions: Developer Role, Least-Privilege Policy, Instance Profile
# ------------------------------------------------------------------------------
module "iam" {
  source      = "./modules/iam"
  environment = var.environment
  team        = "T193"
}

# ------------------------------------------------------------------------------
# 5. CLOUDWATCH MONITORING & SNS ALERTING MODULE (Managed by Team T334)
#    Provisions: SNS Topic, 3x CloudWatch Alarms (root login, unauth API,
#                CloudTrail tampering), metric filters
# ------------------------------------------------------------------------------
module "monitoring" {
  source      = "./modules/monitoring"
  environment = var.environment
  team        = "T334"
  alert_email = var.alert_email
}

# ------------------------------------------------------------------------------
# 6. AWS CONFIG COMPLIANCE MODULE (Managed by Team T193)
#    Provisions: Config Recorder, Delivery Channel, 4x Managed Rules
#                (S3 encryption, S3 public access, CloudTrail enabled, Root MFA)
# ------------------------------------------------------------------------------
module "config" {
  source             = "./modules/config"
  config_bucket_name = var.config_bucket_name
  environment        = var.environment
  team               = "T193"
}

# ------------------------------------------------------------------------------
# 7. AWS BUDGETS MODULE (Managed by Team T334)
#    Provisions: Monthly cost budget ($50), EC2 budget ($20)
#                Both with email alerts at 80% and 100%
# ------------------------------------------------------------------------------
module "budgets" {
  source               = "./modules/budgets"
  environment          = var.environment
  team                 = "T334"
  monthly_budget_limit = var.monthly_budget_limit
  ec2_budget_limit     = var.ec2_budget_limit
  budget_alert_emails  = var.budget_alert_emails
}
