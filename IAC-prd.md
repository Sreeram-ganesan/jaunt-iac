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

---

## 3. Scope

### In Scope (MVP)

* [ ] Terraform repo structure with `modules/` and `envs/`
* [ ] EC2 instance running FastAPI with systemd service
* [ ] Security group with open ports for **22 (SSH)** and **8000 (FastAPI)**
* [ ] IAM instance profile with **S3 FullAccess** (for now)
* [ ] RDS Postgres instance (db.t3.micro, Postgres 16)
* [ ] Remote state backend (S3 + DynamoDB)
* [ ] Cloud-init (`user_data.sh`) to auto-provision Python, clone repo, run service
* [ ] Helper scripts (`deploy.sh`, `ssh.sh`, `curl-health.sh`)
* [ ] Example `terraform.tfvars` with placeholders for API keys

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
* [ ] App can connect to RDS Postgres
* [ ] IaC is modular and can be reused for prod with minimal changes

---

## 5. Architecture

### Components

* **EC2 Instance**: Runs FastAPI app, systemd service, exposes port 8000
* **IAM Role + Instance Profile**: Grants S3 access
* **S3 Buckets**: For logs, artifacts, content storage
* **RDS Postgres**: Stores metadata, jobs, prompt configs
* **VPC & Security Groups**: Default VPC (MVP), tighten later
* **Terraform Modules**: Modular blocks for EC2, IAM, RDS, network
* **Scripts**: Deployment helpers

### High-Level Diagram

```
        +-----------------------------+
        |        AWS Cloud            |
        |                             |
        |   +---------------------+   |
        |   |      S3 Buckets     |   |
        |   +---------------------+   |
        |                             |
        |   +---------------------+   |
        |   |     RDS Postgres    |   |
        |   +---------------------+   |
        |                             |
        |   +---------------------+   |
        |   |       EC2 App       |   |
        |   |  FastAPI + systemd  |   |
        |   |  IAM Role → S3      |   |
        |   |  DB → Postgres      |   |
        |   |  Internet → Tavily  |   |
        |   +---------------------+   |
        |                             |
        +-----------------------------+
```

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

### Example Outputs

* `app_url`: `http://<public-ip>:8000`
* `rds_endpoint`: `<hostname>:5432`

---

## 7. Phased Checklist

### Phase 1: Repo & Terraform Bootstrapping

* [ ] Create `fastapi-infra/` repo
* [ ] Add `.gitignore` (Terraform + secrets)
* [ ] Add Makefile with init/plan/apply/destroy
* [ ] Add S3 backend config for state

### Phase 2: Core Modules

* [ ] `network-min` (default VPC, subnets)
* [ ] `iam-ec2-s3` (role + policy + instance profile)
* [ ] `rds-postgres` (DB, SG, subnet group)
* [ ] `ec2-fastapi` (instance, SG, user\_data.sh)

### Phase 3: Environment Setup

* [ ] `envs/dev` with main.tf wiring modules
* [ ] Example `terraform.tfvars` (API keys, DB creds, repo URL)
* [ ] Outputs: app\_url, rds\_endpoint

### Phase 4: Scripts & Deployment

* [ ] `deploy.sh` → pull latest repo + restart service
* [ ] `ssh.sh` → helper SSH script
* [ ] `curl-health.sh` → test FastAPI health endpoint

### Phase 5: Verification

* [ ] Confirm FastAPI health endpoint works
* [ ] Confirm DB connectivity (psql or app logs)
* [ ] Confirm S3 read/write works
* [ ] Confirm external API calls (Tavily + Gemini) succeed

---