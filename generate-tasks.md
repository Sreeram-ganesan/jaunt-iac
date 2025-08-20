# Task List for FastAPI Infrastructure Deployment

**Generated from:** IAC-prd.md  
**Project:** FastAPI Infra Deployment with Terraform  
**Date:** 2025-08-20  

---

## 🏗️ Infrastructure Foundation

### Task 1: Repository Structure Setup
- [ ] Create `fastapi-infra/` root directory
- [ ] Create `infra/` subdirectory structure:
  - [ ] `infra/envs/` (dev, prod environments)
  - [ ] `infra/modules/` (reusable Terraform modules)
  - [ ] `infra/backend/` (remote state configuration)
  - [ ] `infra/scripts/` (deployment and utility scripts)
- [ ] Create root-level files:
  - [ ] `Makefile` for automation
  - [ ] `README.md` with setup instructions
  - [ ] `.gitignore` for Terraform and AWS files

**Acceptance Criteria:**
- Repository follows exact structure from PRD deliverables
- All directories exist and are properly organized
- .gitignore excludes `.terraform/`, `*.tfstate*`, `*.tfvars` (except examples)

### Task 2: Remote State Backend Configuration  
- [ ] Create S3 bucket for Terraform state storage
- [ ] Create DynamoDB table for state locking
- [ ] Configure backend.tf in `infra/backend/`
- [ ] Test state backend initialization

**Acceptance Criteria:**
- Remote state is properly configured and accessible
- State locking works via DynamoDB
- Multiple team members can work without conflicts

---

## 🔧 Terraform Modules Development

### Task 3: Network Module (`network-min`)
- [ ] Create `infra/modules/network-min/` directory
- [ ] Define VPC configuration (use default VPC for MVP)
- [ ] Create security groups:
  - [ ] Allow SSH (port 22) from anywhere
  - [ ] Allow HTTP (port 8000) from anywhere
  - [ ] Allow outbound internet access for API calls
- [ ] Create module variables, outputs, and main.tf

**Acceptance Criteria:**
- Security groups allow required ports (22, 8000)
- Outbound internet access enabled for Tavily/Gemini APIs
- Module is reusable across environments

### Task 4: IAM Module (`iam-ec2-s3`)
- [ ] Create `infra/modules/iam-ec2-s3/` directory
- [ ] Define IAM role for EC2 instances
- [ ] Attach S3 FullAccess policy (MVP - will tighten later)
- [ ] Create instance profile for EC2 attachment
- [ ] Define module variables and outputs

**Acceptance Criteria:**
- EC2 instances can assume the role
- S3 read/write access is functional
- Instance profile is properly configured

### Task 5: RDS Module (`rds-postgres`)
- [ ] Create `infra/modules/rds-postgres/` directory
- [ ] Support conditional RDS creation based on `use_existing_rds` variable
- [ ] When `use_existing_rds = false`:
  - [ ] Create RDS subnet group
  - [ ] Create db.t3.micro Postgres 16 instance
  - [ ] Configure security group for database access
- [ ] When `use_existing_rds = true`:
  - [ ] Only configure security group rules
  - [ ] Pass through existing RDS connection details
- [ ] Define variables for both scenarios

**Acceptance Criteria:**
- Module works with both existing and new RDS instances
- Database security group allows EC2 access
- Connection parameters are properly exposed

### Task 6: EC2 FastAPI Module (`ec2-fastapi`)
- [ ] Create `infra/modules/ec2-fastapi/` directory
- [ ] Define EC2 instance configuration
- [ ] Attach security groups from network module
- [ ] Attach IAM instance profile
- [ ] Configure user_data script for application deployment
- [ ] Define module variables and outputs (public IP, etc.)

**Acceptance Criteria:**
- EC2 instance starts successfully
- User data script executes without errors
- Instance has proper security groups and IAM role attached

---

## 📦 Environment Configurations

### Task 7: Development Environment
- [ ] Create `infra/envs/dev/` directory
- [ ] Create main.tf that calls all modules
- [ ] Create variables.tf with environment-specific defaults
- [ ] Create outputs.tf for important values
- [ ] Create example terraform.tfvars.example

**Acceptance Criteria:**
- Dev environment can be deployed independently
- All modules are properly integrated
- Example variables file includes all required parameters

### Task 8: Production Environment
- [ ] Create `infra/envs/prod/` directory
- [ ] Create main.tf that calls all modules (same as dev)
- [ ] Create variables.tf with production defaults
- [ ] Create outputs.tf for important values
- [ ] Create example terraform.tfvars.example

**Acceptance Criteria:**
- Prod environment mirrors dev structure
- Environment-specific configurations are separate
- Ready for production deployment

---

## 🚀 Application Deployment

### Task 9: Cloud-Init Script (`user_data.sh`)
- [ ] Create user_data script for EC2 initialization
- [ ] Install required dependencies:
  - [ ] Python 3.x and pip
  - [ ] Git
  - [ ] Required Python packages
- [ ] Clone FastAPI application repository
- [ ] Configure systemd service for FastAPI
- [ ] Start and enable the service
- [ ] Configure logging

**Acceptance Criteria:**
- EC2 instance automatically provisions Python environment
- FastAPI service starts automatically on boot
- Service is accessible on port 8000
- Logs are properly configured

### Task 10: Application Configuration
- [ ] Configure FastAPI app to read from environment variables:
  - [ ] Database connection parameters
  - [ ] API keys for Tavily and Gemini
  - [ ] S3 bucket configurations
- [ ] Create systemd service file template
- [ ] Configure health check endpoint (`/health`)

**Acceptance Criteria:**
- App reads configuration from environment
- Health check returns 200 OK
- Database connection is established
- S3 integration works

---

## 🛠️ Helper Scripts

### Task 11: Deployment Script (`deploy.sh`)
- [ ] Create `infra/scripts/deploy.sh`
- [ ] Implement Terraform initialization
- [ ] Implement plan and apply workflow
- [ ] Add environment selection logic
- [ ] Include error handling and rollback options
- [ ] Add progress indicators

**Acceptance Criteria:**
- Script can deploy to dev or prod environments
- Proper error handling and user feedback
- Rollback capability on failures

### Task 12: SSH Helper Script (`ssh.sh`)
- [ ] Create `infra/scripts/ssh.sh`
- [ ] Auto-discover EC2 instance IP from Terraform output
- [ ] Connect via SSH with proper key
- [ ] Support environment parameter (dev/prod)

**Acceptance Criteria:**
- Automatically connects to deployed EC2 instance
- Works with both dev and prod environments
- Handles SSH key management

### Task 13: Health Check Script (`curl-health.sh`)
- [ ] Create `infra/scripts/curl-health.sh`
- [ ] Query FastAPI health endpoint
- [ ] Validate response status and content
- [ ] Support environment parameter
- [ ] Include comprehensive output

**Acceptance Criteria:**
- Successfully queries health endpoint
- Validates service is running properly
- Provides clear status information

---

## 📝 Documentation and Configuration

### Task 14: Example Configuration Files
- [ ] Create comprehensive `terraform.tfvars.example` with:
  - [ ] Examples for both existing and new RDS scenarios
  - [ ] Placeholder values for API keys
  - [ ] Comments explaining each variable
  - [ ] Environment-specific examples
- [ ] Document variable descriptions in variables.tf files

**Acceptance Criteria:**
- Example files cover all configuration scenarios
- Clear documentation for all variables
- Easy for new users to get started

### Task 15: Main Makefile
- [ ] Create root-level Makefile with targets:
  - [ ] `make dev-deploy` - Deploy to development
  - [ ] `make prod-deploy` - Deploy to production
  - [ ] `make dev-destroy` - Destroy dev environment
  - [ ] `make prod-destroy` - Destroy prod environment
  - [ ] `make ssh-dev` / `make ssh-prod` - SSH to instances
  - [ ] `make health-dev` / `make health-prod` - Check service health
  - [ ] `make clean` - Clean temporary files

**Acceptance Criteria:**
- All common operations have make targets
- Makefile is self-documenting
- Targets work across environments

### Task 16: README Documentation
- [ ] Create comprehensive README.md with:
  - [ ] Project overview and architecture
  - [ ] Prerequisites and setup instructions
  - [ ] Deployment instructions (step-by-step)
  - [ ] Configuration examples
  - [ ] Troubleshooting guide
  - [ ] Future enhancements roadmap

**Acceptance Criteria:**
- New team members can follow README to deploy successfully
- All major use cases are documented
- Troubleshooting covers common issues

---

## ✅ Testing and Validation

### Task 17: Infrastructure Testing
- [ ] Test deployment to dev environment
- [ ] Validate all modules work together
- [ ] Test both RDS scenarios (existing and new)
- [ ] Verify security group configurations
- [ ] Test IAM permissions for S3 access

**Acceptance Criteria:**
- Dev environment deploys without errors
- Both RDS scenarios work correctly
- All network connectivity is functional

### Task 18: Application Integration Testing
- [ ] Verify FastAPI service starts automatically
- [ ] Test health endpoint accessibility
- [ ] Validate external API connectivity (Tavily, Gemini)
- [ ] Test S3 read/write operations
- [ ] Test database connectivity and operations

**Acceptance Criteria:**
- Service is accessible at `http://<public-ip>:8000/health`
- External API calls work (internet connectivity)
- S3 operations function correctly
- Database operations work properly

### Task 19: End-to-End Validation
- [ ] Deploy complete infrastructure
- [ ] Run full application test suite
- [ ] Validate all success criteria from PRD:
  - [ ] Service reachable at health endpoint
  - [ ] Tavily API connectivity works
  - [ ] Gemini API connectivity works
  - [ ] S3 read/write functionality
  - [ ] RDS connectivity (both scenarios)
  - [ ] Infrastructure is modular and reusable

**Acceptance Criteria:**
- All PRD success criteria are met
- Infrastructure is production-ready
- Documentation is complete and accurate

---

## 🔄 Future Enhancements (Out of Scope for MVP)

### Identified for Future Phases:
- [ ] Auto Scaling Groups / Load Balancers
- [ ] TLS termination with ACM + ALB  
- [ ] Private subnets + NAT Gateway
- [ ] Secrets Manager/SSM for key management
- [ ] CI/CD pipelines (GitHub Actions / CodePipeline)

---

## 📊 Progress Tracking

**Total Tasks:** 19 main tasks with multiple sub-tasks  
**Estimated Completion:** TBD based on team capacity  
**Dependencies:** AWS account setup, API keys, existing RDS details (if applicable)

---

*This task list is generated based on requirements from IAC-prd.md and should be updated as implementation progresses.*
