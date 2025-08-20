# Makefile for FastAPI Infrastructure Deployment
# Usage: make <target>

.PHONY: help init-backend backend-destroy test-backend dev-deploy prod-deploy dev-destroy prod-destroy ssh-dev ssh-prod health-dev health-prod clean

# Default target
help:
	@echo "Available targets:"
	@echo "  init-backend    - Initialize Terraform backend infrastructure"
	@echo "  test-backend    - Test backend configuration (validation only)"
	@echo "  backend-destroy - Destroy backend infrastructure (USE WITH CAUTION)"
	@echo "  dev-deploy      - Deploy to development environment"
	@echo "  prod-deploy     - Deploy to production environment" 
	@echo "  dev-destroy     - Destroy development environment"
	@echo "  prod-destroy    - Destroy production environment"
	@echo "  ssh-dev         - SSH to development instance"
	@echo "  ssh-prod        - SSH to production instance"
	@echo "  health-dev      - Check development service health"
	@echo "  health-prod     - Check production service health"
	@echo "  clean           - Clean temporary files"

# Backend infrastructure
init-backend:
	@echo "Initializing Terraform backend infrastructure..."
	cd infra/scripts && ./init-backend.sh

test-backend:
	@echo "Testing Terraform backend configuration..."
	cd infra/scripts && ./test-backend.sh

backend-destroy:
	@echo "WARNING: This will destroy the backend infrastructure!"
	@echo "Make sure no environments are using remote state before proceeding."
	@read -p "Are you sure? (type 'yes' to confirm): " confirmation && [ "$$confirmation" = "yes" ]
	cd infra/backend && terraform destroy

# Development environment
dev-deploy:
	@echo "Deploying to development environment..."
	cd infra/scripts && ./deploy.sh dev

dev-destroy:
	@echo "Destroying development environment..."
	cd infra/scripts && ./deploy.sh dev destroy

ssh-dev:
	@echo "Connecting to development instance..."
	cd infra/scripts && ./ssh.sh dev

health-dev:
	@echo "Checking development service health..."
	cd infra/scripts && ./curl-health.sh dev

# Production environment
prod-deploy:
	@echo "Deploying to production environment..."
	cd infra/scripts && ./deploy.sh prod

prod-destroy:
	@echo "Destroying production environment..."
	cd infra/scripts && ./deploy.sh prod destroy

ssh-prod:
	@echo "Connecting to production instance..."
	cd infra/scripts && ./ssh.sh prod

health-prod:
	@echo "Checking production service health..."
	cd infra/scripts && ./curl-health.sh prod

# Utility targets
clean:
	@echo "Cleaning temporary files..."
	find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.tfstate*" -type f -delete 2>/dev/null || true
	find . -name "crash.log" -type f -delete 2>/dev/null || true
	find . -name "override.tf" -type f -delete 2>/dev/null || true
	find . -name "*_override.tf" -type f -delete 2>/dev/null || true
	find . -name "*.log" -type f -delete 2>/dev/null || true
	@echo "Clean complete!"