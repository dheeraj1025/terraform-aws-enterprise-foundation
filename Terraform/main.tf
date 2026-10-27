# ------------------------------------------------------------------------------
# 1. Security Baseline & Centralized Audit/KMS Module
# ------------------------------------------------------------------------------
module "security_baseline" {
  source = "./modules/security_baseline"

  environment = var.environment
  aws_region  = var.aws_region
}

# ------------------------------------------------------------------------------
# 2. Multi-AZ Network Topology Module
# ------------------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  app_subnet_cidrs     = var.app_subnet_cidrs
  data_subnet_cidrs    = var.data_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
  kms_key_arn          = module.security_baseline.kms_key_arn
  flow_logs_bucket_arn = module.security_baseline.audit_bucket_arn
}

# ------------------------------------------------------------------------------
# 3. IAM Permission Boundaries & Guardrails Module
# ------------------------------------------------------------------------------
module "iam_boundaries" {
  source = "./modules/iam_boundaries"

  environment = var.environment
}
