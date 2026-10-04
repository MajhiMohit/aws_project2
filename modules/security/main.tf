# ------------------------------------------------------------------------------
# SECURITY MODULE: Security Groups & Ingress/Egress Guardrails
# Managed by: Team T193 (Security & Identity Core)
# ------------------------------------------------------------------------------

# 1. Web / Application Tier Security Group
resource "aws_security_group" "web_app_sg" {
  name        = "landingzone-web-app-sg-${var.environment}"
  description = "Controls inbound traffic to Web and Application workloads"
  vpc_id      = var.vpc_id

  # Allow HTTP (Port 80)
  ingress {
    description = "Allow inbound HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS (Port 443)
  ingress {
    description = "Allow inbound HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SECURITY GUARDRAIL: Restrict SSH (Port 22) to designated Admin IP range
  ingress {
    description = "Restricted Admin SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ssh_cidr]
  }

  # Allow outbound internet traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "landingzone-web-app-sg-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}

# 2. Database / Internal Tier Security Group
resource "aws_security_group" "database_sg" {
  name        = "landingzone-database-sg-${var.environment}"
  description = "Controls inbound access to Database tier with strict isolation"
  vpc_id      = var.vpc_id

  # SECURITY GUARDRAIL: Allow DB port 5432 ONLY from the Web/App Security Group
  ingress {
    description     = "Allow PostgreSQL access ONLY from Web/App SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_app_sg.id]
  }

  egress {
    description = "Allow outbound to local VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "landingzone-database-sg-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}
