variable "aws_region" {
  type        = string
  description = "Target AWS deployment region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "production"
}

variable "vpc_cidr" {
  type        = string
  description = "Base CIDR block for the foundation VPC"
  default     = "10.100.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "Target availability zones for multi-AZ topology"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public ingress subnet CIDRs"
  default     = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
}

variable "app_subnet_cidrs" {
  type        = list(string)
  description = "Private application subnet CIDRs"
  default     = ["10.100.10.0/24", "10.100.20.0/24", "10.100.30.0/24"]
}

variable "data_subnet_cidrs" {
  type        = list(string)
  description = "Isolated database and data tier subnet CIDRs"
  default     = ["10.100.100.0/24", "10.100.200.0/24", "10.100.210.0/24"]
}

variable "single_nat_gateway" {
  type        = bool
  description = "Set false for HA production (1 NAT GW per AZ); true to save costs in non-prod"
  default     = false
}
