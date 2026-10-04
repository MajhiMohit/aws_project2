# ------------------------------------------------------------------------------
# VPC MODULE: Provision VPC, Internet Gateway, Subnets, Route Tables,
#             NAT Gateway, and VPC Flow Logs
# Managed by: Team T052 (Networking Core)
# ------------------------------------------------------------------------------

# 1. Primary Landing Zone VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "LandingZone-VPC-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}

# 2. Internet Gateway for Public Internet Access
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "LandingZone-IGW-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}

# 3. Public Subnets across multiple Availability Zones
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "LandingZone-PublicSubnet-${count.index + 1}-${var.environment}"
    Type        = "Public"
    Team        = var.team
    Environment = var.environment
  }
}

# 4. Private Subnets across multiple Availability Zones
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name        = "LandingZone-PrivateSubnet-${count.index + 1}-${var.environment}"
    Type        = "Private"
    Team        = var.team
    Environment = var.environment
  }
}

# 5. Route Table for Public Subnets (Routes 0.0.0.0/0 to Internet Gateway)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "LandingZone-PublicRouteTable-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 6. Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "LandingZone-NAT-EIP-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.gw]
}

# 7. NAT Gateway (placed in first public subnet)
# Allows private subnet instances to reach the internet for updates/patches
# while blocking ALL inbound connections from the internet (security guardrail)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name        = "LandingZone-NAT-GW-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.gw]
}

# 8. Route Table for Private Subnets → routed through NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name        = "LandingZone-PrivateRouteTable-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# ==============================================================================
# VPC FLOW LOGS — Network Traffic Audit (Security Guardrail)
# Captures all Accept/Reject traffic for security monitoring and compliance
# ==============================================================================

# 9. CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flowlogs/${var.environment}"
  retention_in_days = 90

  tags = {
    Name        = "LandingZone-VPCFlowLogs-${var.environment}"
    Team        = var.team
    Environment = var.environment
    Purpose     = "VPC-Network-Audit"
  }
}

# 10. IAM Role allowing VPC Flow Logs to write to CloudWatch
resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "LandingZone-VPCFlowLogsRole-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "LandingZone-VPCFlowLogsRole-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}

# IAM Policy — grants flow logs permission to write to CloudWatch
resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "LandingZone-VPCFlowLogsPolicy-${var.environment}"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

# 11. VPC Flow Log — captures ALL traffic (ACCEPT + REJECT) in the Landing Zone VPC
resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = {
    Name        = "LandingZone-FlowLog-${var.environment}"
    Team        = var.team
    Environment = var.environment
  }
}
