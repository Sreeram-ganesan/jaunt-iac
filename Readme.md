# FastAPI Infrastructure as Code (IaC) with Terraform

A complete Infrastructure as Code solution for deploying FastAPI applications on AWS using Terraform. This project provides modular, reusable Terraform modules for deploying scalable FastAPI infrastructure with support for both development and production environments.

## 🏗️ Architecture Overview

The infrastructure consists of:

- **EC2 Instance**: Runs the FastAPI application with automatic deployment via user_data
- **RDS PostgreSQL**: Database storage (supports both new and existing instances)
- **IAM Roles**: Secure access to AWS services (S3, Systems Manager)
- **Security Groups**: Network access control for SSH, HTTP, and database
- **S3 Integration**: For application data storage and logging
- **External APIs**: Integration with Tavily and Gemini APIs

## 🚀 Quick Start

### Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with credentials
3. **Terraform** >= 1.0 installed
4. **EC2 Key Pair** created in your AWS account
5. **API Keys** for Tavily and Gemini (optional for development)

### 1. Clone and Setup

```bash
git clone <repository-url>
cd jaunt-iac
```

### 2. Configure Environment

Choose development or production environment:

```bash
# For development
cd infra/envs/dev
cp terraform.tfvars.example terraform.tfvars

# For production  
cd infra/envs/prod
cp terraform.tfvars.example terraform.tfvars
```

### 3. Edit Configuration

Edit `terraform.tfvars` with your values:

```hcl
# Required: EC2 Key Pair name (must exist in AWS)
ec2_key_name = "your-key-pair-name"

# Optional: API Keys
tavily_api_key = "your-tavily-api-key"
gemini_api_key = "your-gemini-api-key"

# Optional: S3 Bucket
s3_bucket_name = "your-app-bucket"
```

### 4. Deploy

```bash
# Deploy development environment
make dev-deploy

# Or deploy production environment  
make prod-deploy
```

### 5. Test

```bash
# Check health
make health-dev    # or make health-prod

# SSH to instance
make ssh-dev       # or make ssh-prod
```

## 📁 Project Structure

```
jaunt-iac/
├── infra/
│   ├── modules/              # Reusable Terraform modules
│   │   ├── network-min/      # VPC and security groups
│   │   ├── iam-ec2-s3/      # IAM roles and policies
│   │   ├── rds-postgres/    # RDS PostgreSQL database
│   │   └── ec2-fastapi/     # EC2 instance with FastAPI
│   ├── envs/                # Environment configurations
│   │   ├── dev/             # Development environment
│   │   └── prod/            # Production environment
│   ├── backend/             # Terraform remote state backend
│   └── scripts/             # Deployment and utility scripts
├── Makefile                 # Automation targets
└── README.md               # This file
```

## 🔧 Terraform Modules

### Network Module (`network-min`)
- Default VPC configuration (MVP approach)
- Security groups for SSH (port 22), HTTP (port 8000), outbound internet
- RDS-specific security groups for database access

### IAM Module (`iam-ec2-s3`)
- EC2 IAM role with S3 FullAccess (MVP - tighten in production)
- Instance profile for EC2 attachment
- Optional Systems Manager access for debugging

### RDS Module (`rds-postgres`)
- **Flexible Configuration**: Support for existing or new RDS instances
- **New RDS**: Creates db.t3.micro PostgreSQL 16 with proper security groups
- **Existing RDS**: Uses provided connection details, configures access only
- Automated backups, encryption, and Multi-AZ support (production)

### EC2 Module (`ec2-fastapi`)
- Amazon Linux 2 EC2 instance with FastAPI deployment
- Automated application setup via user_data script
- Systemd service configuration for FastAPI
- Health check endpoints and monitoring

## 🌍 Environment Configurations

### Development Environment
- **Cost-optimized**: t3.micro instances, single AZ RDS
- **Simplified security**: Local password management, minimal backups
- **Easy cleanup**: No deletion protection, skip final snapshots
- **Debug-friendly**: Verbose logging, simplified monitoring

### Production Environment
- **Performance-optimized**: t3.small instances, Multi-AZ RDS
- **Enhanced security**: Secrets Manager integration, deletion protection
- **Reliability**: Automated backups, Elastic IP, encrypted storage
- **Monitoring-ready**: Structured for CloudWatch integration

## 🛠️ Available Commands

### Makefile Targets

```bash
# Backend Management
make init-backend     # Initialize Terraform remote state backend
make test-backend     # Test backend configuration
make backend-destroy  # Destroy backend (use with caution)

# Development Environment
make dev-deploy       # Deploy development environment
make dev-destroy      # Destroy development environment
make ssh-dev          # SSH to development instance
make health-dev       # Check development health

# Production Environment
make prod-deploy      # Deploy production environment
make prod-destroy     # Destroy production environment
make ssh-prod         # SSH to production instance
make health-prod      # Check production health

# Utilities
make clean           # Clean temporary Terraform files
```

### Direct Script Usage

```bash
# Deployment with options
./infra/scripts/deploy.sh dev         # Deploy development
./infra/scripts/deploy.sh dev plan    # Show plan only
./infra/scripts/deploy.sh dev destroy # Destroy environment

# SSH with automatic IP discovery
./infra/scripts/ssh.sh dev            # SSH to development

# Comprehensive health checks
./infra/scripts/curl-health.sh dev          # Basic health check
./infra/scripts/curl-health.sh dev verbose  # Detailed health check
```

## 🗃️ Database Configuration Options

### Option A: Use Existing RDS

```hcl
use_existing_rds     = true
existing_db_host     = "mydb.xxxxx.rds.amazonaws.com"
existing_db_port     = 5432
existing_db_name     = "fastapi_db"
existing_db_username = "admin"
existing_db_password = "your-password"
```

### Option B: Create New RDS

```hcl
use_existing_rds = false

# New RDS configuration
rds_instance_class      = "db.t3.micro"
rds_allocated_storage   = 20
db_name                 = "fastapi_dev"
db_username             = "dbadmin"
# db_password will be auto-generated if not specified
```

## 🔐 Security Considerations

### Development Environment
- ✅ Encrypted EBS volumes
- ✅ IAM roles instead of access keys
- ⚠️ Open security groups (0.0.0.0/0) for simplicity
- ⚠️ Local password management

### Production Environment
- ✅ All development security features
- ✅ AWS Secrets Manager for sensitive data
- ✅ Multi-AZ RDS for high availability
- ✅ Deletion protection enabled
- ✅ Enhanced backup retention
- 🔄 Consider restricting SSH access to specific IPs

### Recommended Production Hardening
1. Restrict SSH security group to specific IP ranges
2. Use private subnets with NAT Gateway (future enhancement)
3. Enable AWS CloudTrail for audit logging
4. Set up CloudWatch monitoring and alerting
5. Implement AWS Config for compliance monitoring

## 🚀 Application Deployment

The FastAPI application is automatically deployed via the `user_data.sh` script:

1. **System Setup**: Updates packages, installs Python 3, pip, git
2. **Application Code**: Clones repository or creates demo application
3. **Dependencies**: Installs FastAPI, uvicorn, database drivers, AWS SDK
4. **Configuration**: Sets up environment variables for database and APIs
5. **Service Setup**: Creates systemd service for automatic startup
6. **Health Checks**: Configures endpoints for monitoring

### Default Application Endpoints

- `http://<public-ip>:8000/` - Root endpoint
- `http://<public-ip>:8000/health` - Health check endpoint
- `http://<public-ip>:8000/api/test` - API connectivity test
- `http://<public-ip>:8000/docs` - FastAPI auto-generated documentation

## 📊 Monitoring and Troubleshooting

### Health Check Examples

```bash
# Basic health check
curl http://<public-ip>:8000/health

# Expected response
{
  "status": "healthy",
  "timestamp": "2024-01-01T12:00:00",
  "environment": "dev",
  "checks": {
    "database": "connected",
    "s3": "accessible"
  }
}
```

### Common Troubleshooting

#### Application won't start
```bash
# SSH to instance
make ssh-dev

# Check service status
sudo systemctl status fastapi-infra

# Check logs
sudo journalctl -u fastapi-infra -f

# Check if port is listening
sudo netstat -tlnp | grep 8000
```

#### Database connection issues
```bash
# Test database connectivity
pg_isready -h <db-host> -p 5432 -U <db-user>

# Check security groups
aws ec2 describe-security-groups --group-ids <rds-sg-id>
```

#### External API issues
```bash
# Test internet connectivity
curl -I https://www.google.com

# Check API credentials in environment
sudo cat /opt/fastapi-infra/.env
```

## 🔧 Customization

### Adding Custom Modules

1. Create new module in `infra/modules/your-module/`
2. Add module call to environment configurations
3. Update variables and outputs as needed

### Modifying Application Deployment

Edit `infra/modules/ec2-fastapi/user_data.sh` to customize:
- Application repository URL
- Dependencies and packages
- Service configuration
- Monitoring setup

### Environment-Specific Overrides

Create `terraform.tfvars` files with environment-specific values:
- Instance types and sizing
- Database configuration
- Security settings
- Monitoring and logging

## 🚦 CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-west-2
          
      - name: Deploy Infrastructure
        run: |
          cd infra/envs/prod
          terraform init
          terraform plan
          terraform apply -auto-approve
```

## 📈 Scaling and Future Enhancements

### Immediate Enhancements (Post-MVP)
- Application Load Balancer with SSL/TLS termination
- Auto Scaling Groups for horizontal scaling
- CloudWatch monitoring and alerting
- AWS Secrets Manager integration for all secrets

### Advanced Features
- Private subnets with NAT Gateway
- AWS WAF for application protection  
- ElastiCache for caching layer
- AWS CodePipeline for automated deployments
- AWS Lambda functions for event processing

## 🆘 Support and Contributing

### Getting Help
1. Check the troubleshooting section above
2. Review Terraform plan output for configuration issues
3. Check AWS CloudWatch logs for runtime issues
4. Verify security group and IAM permissions

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Submit a pull request with description

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 📋 Deployment Checklist

### Before Deployment
- [ ] AWS credentials configured (`aws sts get-caller-identity`)
- [ ] EC2 key pair exists in target region
- [ ] `terraform.tfvars` configured with required values
- [ ] API keys obtained (if using external services)
- [ ] S3 bucket created (if specified)

### After Deployment
- [ ] Health check endpoint responds (`make health-dev`)
- [ ] SSH access works (`make ssh-dev`)
- [ ] Database connectivity verified
- [ ] S3 access tested (if configured)  
- [ ] External API connectivity tested (if configured)
- [ ] Application logs show no errors

### Production Deployment
- [ ] All development checklist items
- [ ] Production API keys configured
- [ ] Monitoring and alerting setup
- [ ] Backup strategy verified
- [ ] Disaster recovery plan documented
- [ ] Security review completed