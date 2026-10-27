```markdown
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

## 1. Network Topology & Isolation Model

The architecture implements a multi-tier, zero-trust network topology spanning 3 Availability Zones (AZs) to ensure high availability and defense-in-depth traffic segmentation:


```

```
                  +-----------------------------+
                  |      Internet Gateway       |
                  +--------------+--------------+
                                 |
=================================v=================================
PUBLIC TIER (ALBs, Bastion, NAT Gateways)
- Subnets: 10.100.1.0/24 (AZ-a) | 10.100.2.0/24 (AZ-b) | 10.100.3.0/24 (AZ-c)
- Route Table: 0.0.0.0/0 -> Internet Gateway (IGW)
- Ingress: External HTTPS/HTTP entry via Application Load Balancer
=================================+=================================
                                 |
                                 | (Egress via NAT Gateways: 1 per AZ)
                                 v
===================================================================
PRIVATE APPLICATION TIER (EC2 Fleets, Container Runtimes)
- Subnets: 10.100.10.0/24 (AZ-a) | 10.100.20.0/24 (AZ-b) | 10.100.30.0/24 (AZ-c)
- Route Table: 0.0.0.0/0 -> AZ-Dedicated NAT Gateway
- Ingress: Strictly limited to traffic originating from Public ALB Security Groups
- Direct Internet Ingress: Denied (No public IPs mapped)
=================================+=================================
                                 |
                                 | (Internal TCP traffic only)
                                 v
===================================================================
ISOLATED DATA TIER (RDS, Aurora, ElastiCache)
- Subnets: 10.100.100.0/24 (AZ-a) | 10.100.200.0/24 (AZ-b) | 10.100.210.0/24 (AZ-c)
- Route Table: Local VPC routing only
- Outbound Route: Completely isolated (No IGW, no NAT route entries)
- Ingress: Strictly restricted to database engine ports (e.g., TCP 5432) from the App Tier SG
===================================================================

```

```

### Subnet Allocation Blueprint

| Subnet Tier | Default CIDR Mask | Target Workloads | Internet Route Type |
| :--- | :--- | :--- | :--- |
| **Public** | `10.100.1.0/24`, `10.100.2.0/24`, `10.100.3.0/24` | ALBs, Bastion, NAT Gateways | Internet Gateway (`0.0.0.0/0`) |
| **Private App** | `10.100.10.0/24`, `10.100.20.0/24`, `10.100.30.0/24` | EC2 Fleets, EKS Worker Nodes | NAT Gateway (`0.0.0.0/0`) |
| **Isolated Data**| `10.100.100.0/24`, `10.100.200.0/24`, `10.100.210.0/24` | RDS, Aurora, ElastiCache | Local VPC Only (No IGW/NAT) |

- **Default Security Group Neutralization:** The default VPC security group is stripped of all inbound and outbound rules to block unauthorized lateral traffic.
- **Fault Domain Isolation:** Each private application subnet routes out through its dedicated, in-zone NAT Gateway, preventing cross-AZ outage propagation.

---

## 2. Security Baselines & Compliance Controls

- **Cryptographic Key Management (AWS KMS CMK):**
  - Customer Managed Key with automated 365-day rotation.
  - Strict IAM key policies granting encryption operations solely to `cloudtrail.amazonaws.com` and `delivery.logs.amazonaws.com`.
- **Audit Storage Hardening (Amazon S3):**
  - **In-Transit Protection:** Explicit bucket policy denying any HTTP payload with `aws:SecureTransport = false`.
  - **Public Exposure Guard:** Full `aws_s3_bucket_public_access_block` covering all four ACL/policy block parameters.
  - **Data Immutability:** S3 object versioning enabled to protect log artifacts against tampering or deletion.
- **Continuous Multi-Region Auditing:**
  - **AWS CloudTrail:** Global multi-region auditing (`is_multi_region_trail = true`) with cryptographic hash validation (`enable_log_file_validation = true`).
  - **VPC Flow Logs:** Captures bidirectional network conversations (`traffic_type = "ALL"`) delivered directly to the encrypted audit S3 bucket.
- **Delegated Administration Guardrails (IAM Boundaries):**
  - Permission boundary restricting delegated IAM roles from disabling CloudTrail, deleting KMS keys, or modifying security baselines.

---

## 3. Module Hierarchy

The infrastructure is broken down into isolated, reusable modules orchestrated from the root layer:

```text
terraform-aws-enterprise-foundation (Root)
│
├── main.tf                 # Orchestrates module invocation and parameter bindings
├── variables.tf            # Global parameter declarations
├── terraform.tfvars        # Concrete production values & CIDR allocations
├── versions.tf             # Terraform core and provider version locks (~> 5.0)
└── outputs.tf              # Exposes core networking and security ARNs
    │
    ├── [1] modules/security_baseline/
    │   ├── main.tf         # KMS CMK, S3 Audit Bucket, CloudTrail
    │   ├── variables.tf    # Environment & region parameters
    │   └── outputs.tf      # Exports: kms_key_arn, audit_bucket_arn, audit_bucket_name
    │
    ├── [2] modules/vpc/
    │   ├── main.tf         # Multi-tier subnets, NAT GWs, route tables, Flow Logs
    │   ├── variables.tf    # Accepts: flow_logs_bucket_arn & kms_key_arn from security_baseline
    │   └── outputs.tf      # Exports: vpc_id, public_subnet_ids, app_subnet_ids, data_subnet_ids
    │
    └── [3] modules/iam_boundaries/
        ├── main.tf         # SCP-style delegated admin IAM permission boundary
        ├── variables.tf    # Environment identifier
        └── outputs.tf      # Exports: boundary_policy_arn

```

**Inter-Module Data Flow:** The root `main.tf` provisions `security_baseline` first. The resulting `audit_bucket_arn` and `kms_key_arn` are then injected directly into `vpc` to configure the VPC Flow Logs destination without circular references.

---

## 4. Module Outputs (outputs.tf)

The root execution layer exposes operational attributes for consumption by downstream application stacks, CI/CD pipelines, and configuration management tools:

| Output Identifier | Type | Description | Source Module |
| --- | --- | --- | --- |
| `vpc_id` | `string` | Base network identifier for workload binding | `module.vpc.vpc_id` |
| `public_subnet_ids` | `list(string)` | Subnets dedicated to ALB and edge ingress | `module.vpc.public_subnet_ids` |
| `app_subnet_ids` | `list(string)` | Subnets dedicated to compute fleets / ASGs | `module.vpc.app_subnet_ids` |
| `data_subnet_ids` | `list(string)` | Isolated subnets for stateful persistence | `module.vpc.data_subnet_ids` |
| `kms_key_arn` | `string` | Centralized KMS key for storage encryption | `module.security_baseline.kms_key_arn` |
| `audit_bucket_name` | `string` | Encrypted central bucket storing audit trails | `module.security_baseline.audit_bucket_name` |
| `iam_boundary_policy_arn` | `string` | Permission boundary policy for delegated roles | `module.iam_boundaries.boundary_policy_arn` |

---

## 5. Deployment Runbook

### Pre-Deployment Setup

1. Clone this repository to your local workspace or CI/CD runner.
2. Initialize and configure your parameters:
```bash
cp terraform.tfvars.example terraform.tfvars

```


3. Edit `terraform.tfvars` with your target AWS Region, VPC CIDR, and Availability Zones.

### Execution Commands

```bash
# Initialize Terraform and download provider plugins
terraform init

# Validate configuration syntax and structural formatting
terraform fmt -check -recursive
terraform validate

# Review proposed changes and speculative execution plan
terraform plan -out=tfplan.binary

# Apply the infrastructure convergence
terraform apply tfplan.binary

```

### Clean Up / Teardown

```bash
terraform destroy

```

```

<FollowUp label="Want me to generate all the files and README for the third repo (ansible-linux-hardening-and-config) using this exact format?" query="Generate all configuration files and the README for ansible-linux-hardening-and-config with the exact same clean formatting and deployment runbook style."/>

```
