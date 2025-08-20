# Makefile for FastAPI Infrastructure Deployment
# Usage: make <target>

.PHONY: help dev-deploy prod-deploy dev-destroy prod-destroy ssh-dev ssh-prod health-dev health-prod clean

# Default target
help:
	@echo "Available targets:"
	@echo "  dev-deploy    - Deploy to development environment"
	@echo "  prod-deploy   - Deploy to production environment" 
	@echo "  dev-destroy   - Destroy development environment"
	@echo "  prod-destroy  - Destroy production environment"
	@echo "  ssh-dev       - SSH to development instance"
	@echo "  ssh-prod      - SSH to production instance"
	@echo "  health-dev    - Check development service health"
	@echo "  health-prod   - Check production service health"
	@echo "  clean         - Clean temporary files"

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