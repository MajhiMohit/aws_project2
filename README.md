# Terraform-Managed AWS Landing Zone – Infrastructure as Code

[![Terraform Version](https://img.shields.io/badge/Terraform->=1.5.0-blue.svg)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS%20Provider-~>5.0-orange.svg)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![Teams](https://img.shields.io/badge/Teams-T052%20|%20T193%20|%20T334-brightgreen.svg)]()
[![Students](https://img.shields.io/badge/Total%20Contributors-12%20Students-purple.svg)]()

> A production-grade, standardized **AWS Landing Zone** built using modular Infrastructure as Code (IaC) with **Terraform**, featuring remote state locking (S3 + DynamoDB), security guardrails, mandatory tagging policies, drift detection, and multi-team collaboration workflows.

---

## Table of Contents
1. [Project Overview & Architecture](#project-overview--architecture)
2. [Folder Structure & Component Interconnection](#folder-structure--component-interconnection)
3. [Prerequisites & System Setup](#prerequisites--system-setup)
4. [Team Task Division (12 Students across 3 Teams)](#team-task-division-12-students-across-3-teams)
5. [S3 Remote State & DynamoDB Lock Setup](#s3-remote-state--dynamodb-lock-setup)
6. [Multi-Team Git/GitHub Workflow & Conflict Prevention](#multi-team-gitgithub-workflow--conflict-prevention)
7. [Step-by-Step Deployment Commands](#step-by-step-deployment-commands)
8. [Infrastructure Drift Detection & Restoration Demo](#infrastructure-drift-detection--restoration-demo)
9. [Security Guardrails & Mandatory Tagging Policy](#security-guardrails--mandatory-tagging-policy)
10. [Faculty Demo Flow](#faculty-demo-flow)
11. [Viva & Technical Interview Q&A](#viva--technical-interview-qa)

---

## Project Overview & Architecture

### What is an AWS Landing Zone?
An **AWS Landing Zone** is a baseline environment provisioned according to cloud best practices. It provides a secure, multi-account or multi-subnet foundation for deploying enterprise applications. Instead of configuring networking, security, and logging manually through the AWS Management Console, this project provisions the entire landing zone using **Terraform**.

### Core Architecture Components
- **VPC & Subnets**: 1 Custom VPC (`10.0.0.0/16`), 2 Public Subnets (Internet-facing), 2 Private Subnets (Isolated Tier), 1 Internet Gateway (IGW), Public & Private Route Tables.
- **Security Core**: Tiered Security Groups (Web/App tier allowing 80/443 & restricted SSH; Database tier allowing port 5432 strictly from Web/App SG).
- **IAM Governance**: Assumable Developer Role attached to a custom Least-Privilege Policy. Explicitly denies destructive actions against audit trails.
- **Audit & Logging**: AWS CloudTrail capturing global and regional API calls, writing encrypted, non-public logs into an S3 bucket with strict Public Access Block.
- **State Management Backend**: S3 bucket with AES256 encryption & versioning + DynamoDB state locking table (`LockID`).

```
                              ┌────────────────────────────────────────────────────────┐
                              │                    AWS Cloud Region                    │
                              │                      (us-east-1)                       │
                              │                                                        │
                              │  ┌──────────────────────────────────────────────────┐  │
                              │  │              Landing Zone VPC (10.0.0.0/16)       │  │
                              │  │                                                  │  │
                              │  │  ┌────────────────────┐  ┌────────────────────┐  │  │
                              │  │  │ Public Subnet 1    │  │ Public Subnet 2    │  │  │
                              │  │  │ (10.0.1.0/24)      │  │ (10.0.2.0/24)      │  │  │
                              │  │  │ Web/App SG         │  │ Web/App SG         │  │  │
                              │  │  └─────────┬──────────┘  └─────────┬──────────┘  │  │
                              │  │            │                     │             │  │
  ┌──────────────────┐        │  │            ▼                     ▼             │  │
  │ Internet Gateway │◄───────┼──┼────────────┴─────────────────────┴───────────┐ │  │
  └──────────────────┘        │  │ │          Route Table (0.0.0.0/0 -> IGW)      │ │  │
                              │  │ └──────────────────────────────────────────────┘ │  │
                              │  │                                                  │  │
                              │  │  ┌────────────────────┐  ┌────────────────────┐  │  │
                              │  │  │ Private Subnet 1   │  │ Private Subnet 2   │  │  │
                              │  │  │ (10.0.10.0/24)     │  │ (10.0.20.0/24)     │  │  │
                              │  │  │ Database SG        │  │ Database SG        │  │  │
                              │  │  └────────────────────┘  └────────────────────┘  │  │
                              │  └──────────────────────────────────────────────────┘  │
                              │                                                        │
                              │  ┌────────────────────┐    ┌────────────────────────┐  │
                              │  │ AWS CloudTrail     │───►│ S3 Audit Log Bucket    │  │
                              │  │ (API Auditing)     │    │ (Public Access Blocked)│  │
                              │  └────────────────────┘    └────────────────────────┘  │
                              └────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        Terraform State Remote Backend Storage                          │
│   ┌─────────────────────────────────────────┐  ┌──────────────────────────────────┐   │
│   │ S3 State Bucket (AES256 + Versioning)   │  │ DynamoDB Lock Table (LockID)     │   │
│   └─────────────────────────────────────────┘  └──────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Folder Structure & Component Interconnection

### Complete Directory Layout
```
terraform-aws-landing-zone/
├── bootstrap/                      # Step 0: Remote State Infrastructure
│   ├── main.tf                     # S3 bucket + DynamoDB locking table resources
│   ├── variables.tf                # Region and bucket/table configuration parameters
│   ├── outputs.tf                  # Outputs bucket name and lock table name
│   └── versions.tf                 # Terraform & AWS provider requirements
├── modules/                        # Reusable Component Modules
│   ├── vpc/                        # Module 1: Networking Core (Team T052)
│   │   ├── main.tf                 # VPC, IGW, Subnets, Route Tables & Associations
│   │   ├── variables.tf            # Subnet CIDRs, AZs, VPC CIDR definitions
│   │   └── outputs.tf              # Returns VPC ID, Subnet IDs for other modules
│   ├── iam/                        # Module 2: IAM & Identity (Team T193)
│   │   ├── main.tf                 # Roles, Policies, Instance Profiles
│   │   ├── variables.tf            # Environment & Team tags
│   │   └── outputs.tf              # Role ARNs & Profile names
│   ├── security/                   # Module 3: Security & Firewall (Team T193)
│   │   ├── main.tf                 # Web/App SG, Restricted SSH, DB isolation SG
│   │   ├── variables.tf            # VPC ID reference & SSH ingress CIDR
│   │   └── outputs.tf              # Security Group IDs
│   └── logging/                    # Module 4: Audit Logging (Team T334)
│       ├── main.tf                 # CloudTrail & Secure Logging S3 Bucket
│       ├── variables.tf            # CloudTrail S3 Bucket parameters
│       └── outputs.tf              # Bucket ARN & Trail ARN
├── backend.tf                      # Configures S3 backend + DynamoDB locking
├── main.tf                         # Root module instantiating all 4 sub-modules
├── outputs.tf                      # Aggregates key deployment outputs
├── provider.tf                     # AWS Provider & Mandatory default_tags block
├── terraform.tfvars                # Real values supplied to root variables
├── variables.tf                    # Root variable definitions
├── versions.tf                     # Constrains Terraform (>= 1.5.0) & AWS Provider (~> 5.0)
└── README.md                       # Complete documentation & project manual
```

### How the Files Connect
1. **`versions.tf`** specifies that Terraform must be `1.5.0` or higher and forces the HashiCorp AWS provider (`~> 5.0`).
2. **`provider.tf`** initializes the AWS provider for region `us-east-1` and sets a mandatory `default_tags` block (`Project`, `Environment`, `ManagedBy`).
3. **`variables.tf`** defines input parameters, which get their actual values from **`terraform.tfvars`**.
4. **`main.tf`** acts as the orchestrator:
   - Passes `vpc_cidr` to `module.vpc`, which returns `module.vpc.vpc_id`.
   - Passes `module.vpc.vpc_id` into `module.security` so security groups attach to the created VPC.
   - Instantiates `module.logging` for audit logging and `module.iam` for developer permissions.
5. **`outputs.tf`** queries outputs from the child modules and presents the final resource IDs (VPC ID, Subnet IDs, CloudTrail ARN, Security Group IDs) after `terraform apply`.
6. **`backend.tf`** instructs Terraform to store `terraform.tfstate` inside the S3 bucket created by `bootstrap/` and acquire mutex locks from DynamoDB.

---

## Prerequisites & System Setup

### 1. AWS Credentials Setup
You need an active AWS Account. Configure your access credentials via terminal:
```bash
aws configure
```
Enter your AWS Access Key ID, Secret Access Key, Default Region (`us-east-1`), and Output format (`json`).

Verify your identity:
```bash
aws sts get-caller-identity
```

### 2. Terraform Installation
- **Windows (winget)**: `winget install HashiCorp.Terraform`
- **Mac (Homebrew)**: `brew install terraform`
- **Linux (apt)**: `sudo apt-get install terraform`

Verify installation:
```bash
terraform -version
```

### 3. Git Configuration
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

---

## Team Task Division (12 Students across 3 Teams)

To ensure seamless coordination without state or file conflicts, the 12 students are divided into 3 specialized teams of 4 members each:

### Team T052: Networking Core (4 Students)
* **Student 1 (Team Lead - Networking)**: Manages root `main.tf` VPC module integration and CIDR allocation plan.
* **Student 2**: Authors `modules/vpc/main.tf` (VPC, Internet Gateway, Subnet provisioning).
* **Student 3**: Authors `modules/vpc/variables.tf` & `outputs.tf` (AZ mapping, subnet outputs).
* **Student 4**: Code reviewer and route table specialist (Public/Private routing logic & testing).

### Team T193: Security & Governance (4 Students)
* **Student 5 (Team Lead - Security)**: Designs security guardrails and mandatory tagging policies in `provider.tf`.
* **Student 6**: Authors `modules/security/main.tf` (Web/App Tier Security Group, SSH restriction).
* **Student 7**: Authors `modules/security/main.tf` DB isolation rules & `modules/security/variables.tf`.
* **Student 8**: Authors `modules/iam/main.tf` (Developer roles, IAM policies, instance profiles).

### Team T334: Logging, Backend & Quality Assurance (4 Students)
* **Student 9 (Team Lead - Ops & QA)**: Builds `bootstrap/` S3 bucket & DynamoDB state locking backend.
* **Student 10**: Authors `modules/logging/main.tf` (CloudTrail configuration & S3 bucket policy).
* **Student 11**: Manages `backend.tf`, state conflict resolution testing, and drift detection simulation.
* **Student 12**: Manages GitHub Repository, Pull Requests, documentation, and Viva presentation deck.

---

## S3 Remote State & DynamoDB Lock Setup

When multiple students work on the same infrastructure, local state files (`terraform.tfstate`) lead to:
1. **State Overwrites**: Student A applies changes, overwriting Student B's state file.
2. **Race Conditions**: Two students running `terraform apply` at the same second corrupt AWS resources.

### Solution Architecture: S3 + DynamoDB Mutex Locking
1. **S3 Bucket**: Stores the centralized `terraform.tfstate` file with **Versioning Enabled** (allows rollback if state is damaged) and **Encryption (AES256)**.
2. **DynamoDB Table**: Provides **Distributed Locking**. Before executing changes, Terraform writes a lock item containing a unique UUID into DynamoDB. If another student attempts `terraform apply`, Terraform detects the existing lock and aborts with error: `Error acquiring the state lock`.

### Bootstrapping the Backend (Execute ONCE per project)
```bash
# Navigate to bootstrap folder
cd bootstrap

# Initialize and create S3 bucket + DynamoDB table
terraform init
terraform apply -auto-approve

# Note down the created bucket name and DynamoDB table name from outputs
```

Next, update `backend.tf` in the project root by adding your bucket name and uncommenting the configuration:
```hcl
terraform {
  backend "s3" {
    bucket         = "t-landingzone-tfstate-bucket-unique"
    key            = "landing-zone/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "t-landingzone-tfstate-locks"
    encrypt        = true
  }
}
```

Then initialize remote state in the main repository:
```bash
cd ..
terraform init
```
*(Terraform will prompt: "Do you want to copy existing state to the new backend?". Type `yes`.)*

---

## Multi-Team Git/GitHub Workflow & Conflict Prevention

### GitHub Repository Setup & Branching Rules
1. Create a central repository: `github.com/your-org/terraform-aws-landing-zone`.
2. Protect the `main` branch: Require pull request reviews and passing status checks before merging.
3. Feature Branch Convention:
   - `feature/t052-vpc-subnets`
   - `feature/t193-security-groups`
   - `feature/t334-cloudtrail-logging`

### Daily Student Workflow
```bash
# 1. Pull latest merged code from main branch
git checkout main
git pull origin main

# 2. Create your task branch
git checkout -b feature/t193-add-db-security-group

# 3. Make code changes in your dedicated module folder
# (e.g., editing modules/security/main.tf)

# 4. Format and Validate code locally
terraform fmt -recursive
terraform validate

# 5. Commit and push changes
git add modules/security/
git commit -m "feat(security): add db security group with ingress restriction"
git push origin feature/t193-add-db-security-group

# 6. Open a Pull Request (PR) on GitHub for Team Lead review.
```

### How State Locking Protects 12 Students
```
Student A (Terminal 1)                   DynamoDB State Lock Table                   Student B (Terminal 2)
        │                                            │                                        │
        ├───────── terraform apply ─────────────────►│                                        │
        │                                            │                                        │
        │   Acquires Lock (ID: 9a8b7c)               │                                        │
        │◄───────────────────────────────────────────┤                                        │
        │                                            │                                        │
        │                                            │◄───────── terraform apply ─────────────┤
        │                                            │                                        │
        │                                            │    Lock exists! Action Denied:         │
        │                                            ├───────────────────────────────────────►│
        │                                            │    "Error acquiring state lock"        │
        │                                            │                                        │
        ├───────── Apply Completed ─────────────────►│                                        │
        │                                            │                                        │
        │   Releases Lock (ID: 9a8b7c)               │                                        │
        │◄───────────────────────────────────────────┤                                        │
```

---

## Step-by-Step Deployment Commands

Execute the following commands from the root directory (`terraform-aws-landing-zone/`):

### Step 1: Format Code
Enforces standard HashiCorp HCL formatting conventions across all files:
```bash
terraform fmt -recursive
```

### Step 2: Initialize Workspace
Downloads required providers (HashiCorp AWS `~> 5.0`) and initializes modules:
```bash
terraform init
```

### Step 3: Validate Syntax
Performs static sanity checks on code syntax, variables, and module calls:
```bash
terraform validate
```

### Step 4: Preview Execution Plan
Generates a dry-run execution plan showing resources to be created, modified, or destroyed:
```bash
terraform plan -out=tfplan
```

### Step 5: Provision Infrastructure
Applies the execution plan to provision resources in your AWS account:
```bash
terraform apply tfplan
```
*(Or run `terraform apply` and type `yes` when prompted).*

### Step 6: Verify Outputs
View created outputs at any time:
```bash
terraform output
```

### Step 7: Teardown Infrastructure (Post-Lab)
To destroy all provisioned AWS resources and avoid AWS charges:
```bash
terraform destroy -auto-approve
```

---

## Infrastructure Drift Detection & Restoration Demo

**Infrastructure Drift** occurs when resources managed by Terraform are manually modified outside of Terraform (e.g., via AWS Console, CLI, or SDK). Terraform detects drift by comparing actual cloud state with the target state recorded in `.tfstate`.

### Step-by-Step Drift Demo Instructions

#### 1. Provision Landing Zone Baseline
Run `terraform apply` to ensure all resources match code.

#### 2. Introduce Manual Drift via AWS Console (or CLI)
Simulate a team member manually editing a Security Group rule via AWS CLI (or AWS Console):
```bash
# Query the Web App Security Group ID from terraform output
SG_ID=$(terraform output -raw web_app_security_group_id)

# Manually add an unauthorized inbound rule (Port 8080 open to the world)
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 8080 \
  --cidr 0.0.0.0/0
```

#### 3. Run Drift Detection
Execute `terraform plan`:
```bash
terraform plan
```

#### 4. Observe Drift Output
Terraform detects the unauthorized rule added manually in AWS Console and displays:
```diff
  # module.security.aws_security_group.web_app_sg will be updated in-place
  ~ resource "aws_security_group" "web_app_sg" {
        id                   = "sg-0a1b2c3d4e5f6g7h8"
        name                 = "landingzone-web-app-sg-Dev"
      ~ ingress {
          - cidr_blocks      = [
              - "0.0.0.0/0",
            ] -> null
          - from_port        = 8080 -> null
          - protocol         = "tcp" -> null
          - to_port          = 8080 -> null
        }
        # (3 unchanged ingress statements remain)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

#### 5. Restore Desired State (Self-Healing)
Run `terraform apply` to revoke the unapproved manual changes and align AWS with git code:
```bash
terraform apply -auto-approve
```
*Result: Terraform removes port 8080 ingress rule automatically, restoring security posture!*

---

## Security Guardrails & Mandatory Tagging Policy

### 1. Mandatory Tagging Policy
Implemented directly inside `provider.tf` using `default_tags`:
```hcl
default_tags {
  tags = {
    Project     = "Terraform-AWS-Landing-Zone"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}
```
*Effect*: Every EC2 instance, VPC, Subnet, Route Table, S3 bucket, and Security Group automatically inherits these tags. Resources missing required tags can be flagged for automated destruction in enterprise setups.

### 2. S3 Public Access Block
Enforced on both state and audit logging buckets in `modules/logging/main.tf`:
```hcl
resource "aws_s3_bucket_public_access_block" "cloudtrail_bucket_pab" {
  bucket                  = aws_s3_bucket.cloudtrail_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### 3. Least-Privilege IAM Policy
Implemented in `modules/iam/main.tf`: Explicitly grants necessary operational permissions while placing an explicit `Deny` on destructive audit operations (`cloudtrail:DeleteTrail`, `s3:DeleteBucket`).

### 4. Restricted Admin SSH Port
Implemented in `modules/security/main.tf`: SSH (Port 22) is restricted to specific corporate CIDR IP blocks (`var.admin_ssh_cidr`) rather than `0.0.0.0/0`.

---

## Faculty Demo Flow

When presenting this project to evaluation faculty or external reviewers, follow this 5-minute live demonstration flow:

1. **Architecture & Module Overview (1 min)**:
   - Display project folder structure and explain module decoupling (`vpc`, `iam`, `security`, `logging`).
   - Highlight `provider.tf` `default_tags` block.

2. **Remote Backend & State Locking Verification (1 min)**:
   - Show `backend.tf` pointing to S3 bucket and DynamoDB table.
   - Run `terraform init` to demonstrate remote state initialization.

3. **Deployment Run (1 min)**:
   - Execute `terraform plan` and explain the resource dependency graph.
   - Execute `terraform apply` and display output variables (VPC ID, Subnets, CloudTrail ARN).

4. **Live Drift Detection Demonstration (1.5 min)**:
   - Open AWS Management Console (or run AWS CLI command) and manually add a Security Group rule or bucket tag.
   - Run `terraform plan` in terminal. Point out how Terraform identifies the drift.
   - Run `terraform apply` to show automatic state restoration.

5. **Multi-Team Workflow Explanation (0.5 min)**:
   - Explain how 12 students across Teams T052, T193, and T334 collaborate using GitHub PRs and DynamoDB locking.

---

## Viva & Technical Interview Q&A

### Q1: What is a Terraform Landing Zone and why is it important?
**Answer**: A Landing Zone is a well-architected, multi-account or multi-subnet AWS baseline environment that configures networking, security controls, IAM, and centralized audit logging before workloads are deployed. Building it with Terraform ensures that the infrastructure is reproducible, version-controlled, audited, and immune to manual setup errors.

### Q2: How does DynamoDB prevent state corruption when 12 students work together?
**Answer**: Terraform uses DynamoDB for distributed mutex locking. When a developer executes `terraform plan` or `terraform apply`, Terraform writes an item containing a unique Lock ID to the DynamoDB table. If another developer attempts an apply at the same time, Terraform reads the table, sees the active lock, and rejects the command with an error message until the first developer's run completes and releases the lock.

### Q3: What is Infrastructure Drift and how does Terraform handle it?
**Answer**: Drift happens when real-world cloud resources diverge from the configuration stored in `.tfstate` (usually due to manual AWS Console edits or emergency hotfixes). Running `terraform plan` refreshes the current state against AWS APIs, compares it with the `.tf` code, and generates a plan to reverse out-of-band changes to restore the desired declarative state.

### Q4: Why use Terraform modules instead of a single `main.tf` file?
**Answer**: Modules promote code reusability, maintainability, and clean separation of concerns. In our 12-student project, modularization allowed Team T052 to work independently on `modules/vpc` without touching Team T193's `modules/security` or Team T334's `modules/logging`.

### Q5: How do `default_tags` in the AWS Provider work?
**Answer**: In AWS Provider v4/v5, the `default_tags` block inside the `provider "aws"` definition automatically attaches standard tags (e.g., `Project`, `Environment`, `ManagedBy`) to all taggable AWS resources created by the provider block, eliminating boilerplate code and ensuring 100% compliance with organization tagging guardrails.

### Q6: What is the purpose of `terraform.tfstate.backup`?
**Answer**: It is a snapshot of the state file taken immediately before Terraform makes changes during an apply. If an apply fails mid-way, the backup file can help recover state. In our production setup, S3 bucket versioning handles state backup automatically.

### Q7: What is the difference between `terraform plan` and `terraform apply`?
**Answer**: `terraform plan` is a non-destructive read-only execution that compares the state against AWS and outputting proposed changes. `terraform apply` performs actual API calls to AWS to create, update, or delete infrastructure to match the configuration.

### Q8: How is least privilege implemented in the IAM module?
**Answer**: In `modules/iam/main.tf`, developer roles are attached to custom policies that grant operational access (e.g., managing EC2/VPC instances) while explicitly using `Deny` statements for destructive compliance actions (such as `cloudtrail:DeleteTrail` or `s3:DeleteBucket`). In IAM, an explicit `Deny` always overrides an `Allow`.

### Q9: Why is S3 Bucket Versioning required for remote state?
**Answer**: S3 versioning keeps a history of every `.tfstate` revision uploaded. If a state file becomes corrupted due to network failure or human error, developers can restore a previous state version with a single command.

### Q10: What happens if a developer forgets to run `terraform fmt`?
**Answer**: In a CI/CD pipeline (such as GitHub Actions), `terraform fmt -check` is executed as a quality gate. If the code is not formatted according to standard HashiCorp guidelines, the build job fails and blocks the PR from being merged.

---

### Project Maintainers & Team Credits
- **Team T052 (Networking Core)**: 4 Students
- **Team T193 (Security & Governance)**: 4 Students
- **Team T334 (Audit Logging & Ops)**: 4 Students
