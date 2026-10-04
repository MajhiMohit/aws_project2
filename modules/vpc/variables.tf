variable "vpc_cidr" {
  type        = string
  description = "Base CIDR block for the Landing Zone VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDRs for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDRs for private subnets"
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones to place subnets into"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "environment" {
  type        = string
  description = "Deployment environment name (Dev, Test, Prod)"
  default     = "Dev"
}

variable "team" {
  type        = string
  description = "Team identifier (T052, T193, T334)"
  default     = "T052"
}
