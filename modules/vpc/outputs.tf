output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the provisioned Landing Zone VPC"
}

output "vpc_cidr_block" {
  value       = aws_vpc.main.cidr_block
  description = "The CIDR block of the provisioned VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "List of IDs of the provisioned public subnets"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "List of IDs of the provisioned private subnets"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.gw.id
  description = "The ID of the Internet Gateway"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.main.id
  description = "The ID of the NAT Gateway (Team T052)"
}

output "nat_gateway_public_ip" {
  value       = aws_eip.nat.public_ip
  description = "The public IP address of the NAT Gateway Elastic IP"
}

output "flow_log_id" {
  value       = aws_flow_log.main.id
  description = "The ID of the VPC Flow Log resource"
}

output "flow_log_cloudwatch_group" {
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
  description = "CloudWatch Log Group name for VPC Flow Logs"
}

