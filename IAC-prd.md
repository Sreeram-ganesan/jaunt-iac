Got it 👍 — I’ll keep your PRD mostly intact and only **add the new flexibility for RDS (existing vs new)** without deleting your existing details. Here’s the updated Markdown:

---

# Product Requirements Document (PRD)

**Project:** FastAPI Infra Deployment with Terraform
**Owner:** \[Your Name / Team]
**Date:** 2025-08-20
**Status:** Draft

---

## 1. Overview

We need to deploy our **FastAPI service** (that powers location content generation) to AWS using **Infrastructure as Code (IaC)** with Terraform. The deployment must support:

* Running the **FastAPI app** on an EC2 instance.
* Secure access to **S3 buckets** (read/write).
* Secure access to **RDS Postgres** (for metadata, prompts, job queue).

  * **Option A:** Connect to an **existing RDS instance** (user supplies endpoint/credentials).
  * **Option B:** Provision a **new RDS instance** (default if no existing config provided).
* Internet connectivity for calling **Tavily** and **Gemini** APIs.
* Modular infrastructure that is **scalable** and **environment-ready** (dev/prod).
* Git-friendly repo structure for continuous improvement.

---

## 2. Goals & Objectives

* ✅ Deploy a **minimal but production-viable infra**.
* ✅ Enable **future extensibility** (add ALB, Secrets Manager, scaling, private subnets later).
* ✅ Provide **repeatable IaC** for dev/prod environments.
* ✅ Automate deployment (Makefile + scripts).
* ✅ Track progress with clear stepwise tasks.
* ✅ Give teams the **choice to reuse existing RDS** (faster, cheaper) or **provision new** (full control).

---

## 3. Scope

### In Scope (MVP)

* [ ] Terraform repo structure with `modules/` and `envs/`
* [ ] EC2 instance running FastAPI with systemd service
* [ ] Security group with open ports for **22 (SSH)** and **8000 (FastAPI)**
* [ ] IAM instance profile with **S3 FullAccess** (for now)
* [ ] **RDS Postgres connectivity**:

  * [ ] If `use_existing_rds = true`, only configure security groups and connection params
  * [ ] If `use_existing_rds = false`, create new RDS instance (db.t3.micro, Postgres 16)
* [ ] Remote state backend (S3 + DynamoDB)
* [ ] Cloud-init (`user_data.sh`) to auto-provision Python, clone repo, run service
* [ ] Helper scripts (`deploy.sh`, `ssh.sh`, `curl-health.sh`)
* [ ] Example `terraform.tfvars` with placeholders for API keys and DB configuration

### Out of Scope (Future Phases)

* Auto Scaling Groups / Load Balancers
* TLS termination with ACM + ALB
* Private subnets + NAT Gateway
* Secrets Manager/SSM for key mgmt
* CI/CD pipelines (GitHub Actions / CodePipeline)

---

## 4. Success Criteria

* [ ] Service deployed on EC2, reachable at `http://<public-ip>:8000/health`
* [ ] EC2 instance can call **Tavily API** (internet access works)
* [ ] EC2 instance can connect to **Gemini API** (internet access works)
* [ ] App can read/write to S3 buckets
* [ ] App can connect to **RDS Postgres (existing or new, depending on config)**
* [ ] IaC is modular and can be reused for prod with minimal changes

---

## 5. Architecture

### Components

* **EC2 Instance**: Runs FastAPI app, systemd service, exposes port 8000
* **IAM Role + Instance Profile**: Grants S3 access
* **S3 Buckets**: For logs, artifacts, content storage
* **RDS Postgres**: Stores metadata, jobs, prompt configs

  * **Existing RDS:** Use provided connection details
  * **New RDS:** Terraform creates db.t3.micro with Postgres 16
* **VPC & Security Groups**: Default VPC (MVP), tighten later
* **Terraform Modules**: Modular blocks for EC2, IAM, RDS, network
* **Scripts**: Deployment helpers

---

## 6. Deliverables

### Repo Structure

```
fastapi-infra/
├─ infra/
│  ├─ envs/ (dev, prod)
│  ├─ modules/ (ec2-fastapi, rds-postgres, iam-ec2-s3, network-min)
│  ├─ backend/ (remote state config)
│  └─ scripts/ (deploy, ssh, curl-health)
├─ Makefile
├─ README.md
└─ .gitignore
```

### Example `terraform.tfvars`

```hcl
# Option A: Use existing RDS
use_existing_rds = true
db_host     = "mydb.xxxxx.rds.amazonaws.com"
db_name     = "fastapi_db"
db_user     = "admin"
db_password = "changeme"

# Option B: Create new RDS
use_existing_rds = false
rds_instance_class = "db.t3.micro"
rds_engine_version = "16.2"
```

---
