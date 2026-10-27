# AWS Enterprise Multi-AZ Foundation

Modular Terraform baseline implementing a multi-tier AWS network topology, centralized audit logging with KMS customer-managed keys (CMK), automated VPC Flow Logs, and IAM permission boundaries.

---

## Core Capabilities

- **Multi-Tier Network Isolation:** Dedicated subnets across 3 Availability Zones separating Public Ingress, Private Application workloads, and Isolated Database/Data layers.
- **Strict Network Egress Controls:** Data tier subnets are completely isolated with zero default internet routing; application subnets route strictly through dedicated NAT Gateways.
- **Centralized Compliance & Logging:** Dedicated S3 audit bucket enforcing TLS 1.2+, SSE-KMS customer-managed encryption, bucket versioning, and public access blocks.
- **Multi-Region Audit Trails:** CloudTrail enabled across all regions with log validation and automated VPC Flow Logs capture to S3.
- **IAM Permission Boundaries:** Automated guardrail policy preventing privilege escalation and protecting security infrastructure across delegated roles.

---

## Repository Layout

```text
├── modules/
│   ├── vpc/                    # Multi-AZ subnets, NAT Gateways, Flow Logs, route tables
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security_baseline/      # CloudTrail, KMS CMK, encrypted audit S3 bucket
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── iam_boundaries/         # Guardrail boundary policy for delegated IAM roles
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── main.tf                     # Root orchestration module
├── variables.tf                # Global input variables
├── terraform.tfvars            # Production environment variable assignments
├── outputs.tf                  # Exported VPC IDs, subnet tiers, and KMS ARNs
├── versions.tf                 # Terraform core and AWS provider versions
└── .gitignore
