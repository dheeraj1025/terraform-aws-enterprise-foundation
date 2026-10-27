output "vpc_id" {
  description = "The ID of the provisioned foundation VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public ingress subnets"
  value       = module.vpc.public_subnet_ids
}

output "app_subnet_ids" {
  description = "IDs of the private application tier subnets"
  value       = module.vpc.app_subnet_ids
}

output "data_subnet_ids" {
  description = "IDs of the isolated data tier subnets"
  value       = module.vpc.data_subnet_ids
}

output "kms_key_arn" {
  description = "ARN of the centralized security baseline KMS CMK"
  value       = module.security_baseline.kms_key_arn
}

output "audit_bucket_name" {
  description = "S3 bucket storing centralized CloudTrail and Flow Logs"
  value       = module.security_baseline.audit_bucket_name
}

output "iam_boundary_policy_arn" {
  description = "ARN of the IAM permission boundary for delegation"
  value       = module.iam_boundaries.boundary_policy_arn
}
