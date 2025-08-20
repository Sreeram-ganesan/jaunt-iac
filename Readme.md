# FastAPI Infrastructure Deployment with Terraform

**Project:** FastAPI Infrastructure as Code (IaC) deployment  
**Date:** 2025-08-20  
**Status:** In Development  

## Overview

This repository contains Infrastructure as Code (IaC) using Terraform to deploy a FastAPI service to AWS. The deployment supports:

- **FastAPI application** running on EC2 instance
- **RDS Postgres** connectivity (existing or new instance)
- **S3 bucket** access for storage
- **External API** connectivity (Tavily, Gemini APIs)
- **Modular infrastructure** for dev/prod environments

## Repository Structure

```
jaunt-iac/
├── infra/
│   ├── envs/           # Environment configurations (dev, prod)
│   │   ├── dev/
│   │   └── prod/
│   ├── modules/        # Reusable Terraform modules
│   ├── backend/        # Remote state configuration
│   └── scripts/        # Deployment and utility scripts
├── Makefile           # Automation commands
├── README.md          # This file
├── .gitignore         # Git ignore rules
├── IAC-prd.md         # Product Requirements Document
└── generate-tasks.md  # Task list and progress tracking
```

## Prerequisites

- **AWS CLI** configured with appropriate credentials
- **Terraform** >= 1.0 installed
- **Make** utility for running automation commands
- **SSH key pair** for EC2 access
- **API keys** for Tavily and Gemini services

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd jaunt-iac
   ```

2. **Set up remote state backend** (one-time setup)
   ```bash
   # Test the backend configuration first
   make test-backend
   
   # Configure backend variables
   cp infra/backend/terraform.tfvars.example infra/backend/terraform.tfvars
   # Edit infra/backend/terraform.tfvars with your AWS region and bucket name
   
   # Initialize the backend infrastructure
   make init-backend
   ```

3. **Configure environment variables**
   ```bash
   # Copy example configuration (when available)
   cp infra/envs/dev/terraform.tfvars.example infra/envs/dev/terraform.tfvars
   # Edit with your specific values
   ```

4. **Deploy to development**
   ```bash
   make dev-deploy
   ```

5. **Check service health**
   ```bash
   make health-dev
   ```

## Available Commands

Run `make help` to see all available commands:

### Backend Management
- `make init-backend` - Initialize Terraform backend infrastructure (S3 + DynamoDB)
- `make test-backend` - Test backend configuration (validation only)
- `make backend-destroy` - Destroy backend infrastructure (USE WITH CAUTION)

### Environment Management
- `make dev-deploy` - Deploy to development environment
- `make prod-deploy` - Deploy to production environment  
- `make dev-destroy` - Destroy development environment
- `make prod-destroy` - Destroy production environment

### Operations
- `make ssh-dev` - SSH to development instance
- `make ssh-prod` - SSH to production instance
- `make health-dev` - Check development service health
- `make health-prod` - Check production service health
- `make clean` - Clean temporary files

## Configuration

### Environment Variables

The FastAPI application expects the following environment variables:

- `DB_HOST` - Database hostname
- `DB_NAME` - Database name
- `DB_USER` - Database username  
- `DB_PASSWORD` - Database password
- `TAVILY_API_KEY` - Tavily API key
- `GEMINI_API_KEY` - Gemini API key
- `AWS_REGION` - AWS region for S3 operations

### RDS Configuration Options

**Option A: Use Existing RDS**
```hcl
use_existing_rds = true
db_host     = "mydb.xxxxx.rds.amazonaws.com"
db_name     = "fastapi_db"
db_user     = "admin"
db_password = "changeme"
```

**Option B: Create New RDS**  
```hcl
use_existing_rds = false
rds_instance_class = "db.t3.micro"
rds_engine_version = "16.2"
```

## Success Criteria

- ✅ Service deployed on EC2, reachable at `http://<public-ip>:8000/health`
- ✅ EC2 instance can call **Tavily API** (internet access works)
- ✅ EC2 instance can connect to **Gemini API** (internet access works)
- ✅ App can read/write to S3 buckets
- ✅ App can connect to **RDS Postgres** (existing or new, depending on config)
- ✅ IaC is modular and can be reused for prod with minimal changes

## Development Status

This project is currently under active development. See `generate-tasks.md` for detailed progress tracking and task list.

## Troubleshooting

### Common Issues

1. **Terraform state conflicts**
   ```bash
   # Clean state and retry
   make clean
   terraform init
   ```

2. **SSH connection issues**
   ```bash
   # Verify security groups allow SSH (port 22)
   # Check that SSH key is properly configured
   ```

3. **Service not accessible**
   ```bash
   # Verify security groups allow port 8000
   # Check service status on EC2 instance
   make ssh-dev
   sudo systemctl status fastapi
   ```

## Support

For questions or issues, please refer to the task list in `generate-tasks.md` or check the PRD in `IAC-prd.md` for detailed requirements.