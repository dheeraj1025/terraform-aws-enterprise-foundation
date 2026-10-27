aws_region          = "us-east-1"
environment         = "production"
vpc_cidr            = "10.100.0.0/16"
availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]

public_subnet_cidrs = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
app_subnet_cidrs    = ["10.100.10.0/24", "10.100.20.0/24", "10.100.30.0/24"]
data_subnet_cidrs   = ["10.100.100.0/24", "10.100.200.0/24", "10.100.210.0/24"]

single_nat_gateway  = false
