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

## Subnet Allocation Blueprint

| Subnet Tier | Default CIDR Mask | Target Workloads | Internet Route Type |
| :--- | :--- | :--- | :--- |
| **Public** | `10.100.1.0/24`, `10.100.2.0/24`, `10.100.3.0/24` | ALBs, Bastion, NAT Gateways | Internet Gateway (`0.0.0.0/0`) |
| **Private App** | `10.100.10.0/24`, `10.100.20.0/24`, `10.100.30.0/24` | EC2 Fleets, EKS Worker Nodes | NAT Gateway (`0.0.0.0/0`) |
| **Isolated Data**| `10.100.100.0/24`, `10.100.200.0/24`, `10.100.210.0/24` | RDS, Aurora, ElastiCache | Local VPC Only (No IGW/NAT) |

---

## Prerequisites

- AWS CLI configured with administrator privileges
- Terraform `>= 1.5.0`
- Target AWS account with permissions for VPC, EC2, KMS, S3, CloudTrail, and IAM

---

## Deployment & Verification

### 1. Initialize Modules and Provider Plugins
```bash
terraform init
