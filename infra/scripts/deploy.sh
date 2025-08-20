#!/bin/bash
set -e

# Deploy FastAPI Infrastructure using Terraform
# Usage: ./deploy.sh <environment> [action]
# Example: ./deploy.sh dev
#          ./deploy.sh prod
#          ./deploy.sh dev destroy

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper function for colored output
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check arguments
ENV="$1"
ACTION="${2:-deploy}"

if [[ -z "$ENV" ]] || [[ ! "$ENV" =~ ^(dev|prod)$ ]]; then
    echo "Usage: $0 <dev|prod> [deploy|destroy|plan]"
    echo ""
    echo "Examples:"
    echo "  $0 dev           # Deploy to development"
    echo "  $0 prod          # Deploy to production"
    echo "  $0 dev destroy   # Destroy development environment"
    echo "  $0 dev plan      # Show Terraform plan without applying"
    exit 1
fi

if [[ ! "$ACTION" =~ ^(deploy|destroy|plan)$ ]]; then
    error "Invalid action: $ACTION. Must be 'deploy', 'destroy', or 'plan'"
    exit 1
fi

# Set directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="${SCRIPT_DIR}/../envs/$ENV"

if [[ ! -d "$ENV_DIR" ]]; then
    error "Environment directory not found: $ENV_DIR"
    exit 1
fi

# Banner
echo "🚀 FastAPI Infrastructure Deployment"
echo "======================================"
echo "Environment: $ENV"
echo "Action: $ACTION"
echo "Directory: $ENV_DIR"
echo ""

cd "$ENV_DIR"

# Pre-deployment checks
log "Running pre-deployment checks..."

# Check if terraform.tfvars exists
if [[ ! -f "terraform.tfvars" ]] && [[ "$ACTION" != "plan" ]]; then
    warning "terraform.tfvars not found!"
    echo "Please copy terraform.tfvars.example to terraform.tfvars and configure it."
    echo "Example:"
    echo "  cp terraform.tfvars.example terraform.tfvars"
    echo "  # Edit terraform.tfvars with your values"
    
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error "Operation cancelled"
        exit 1
    fi
fi

# Check AWS credentials
log "Checking AWS credentials..."
if ! aws sts get-caller-identity &>/dev/null; then
    error "AWS credentials not configured or invalid"
    echo "Please configure your AWS credentials using:"
    echo "  aws configure"
    echo "  # or set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
    exit 1
fi

# Initialize Terraform
log "Initializing Terraform..."
terraform init -upgrade

# Validate configuration
log "Validating Terraform configuration..."
if ! terraform validate; then
    error "Terraform validation failed"
    exit 1
fi

# Handle different actions
case "$ACTION" in
    "plan")
        log "Generating Terraform plan..."
        terraform plan -detailed-exitcode
        exit_code=$?
        
        case $exit_code in
            0)
                success "No changes needed"
                ;;
            1)
                error "Terraform plan failed"
                exit 1
                ;;
            2)
                warning "Changes detected - review the plan above"
                ;;
        esac
        ;;
        
    "destroy")
        warning "This will DESTROY all resources in the $ENV environment!"
        if [[ "$ENV" == "prod" ]]; then
            warning "You are about to destroy the PRODUCTION environment!"
            echo "Type 'destroy-$ENV' to confirm:"
            read -r confirmation
            if [[ "$confirmation" != "destroy-$ENV" ]]; then
                error "Operation cancelled"
                exit 1
            fi
        else
            read -p "Are you sure you want to destroy the $ENV environment? (y/N): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                error "Operation cancelled"
                exit 1
            fi
        fi
        
        log "Destroying Terraform infrastructure for $ENV..."
        terraform destroy -auto-approve
        success "$ENV environment destroyed successfully!"
        ;;
        
    "deploy")
        # Show plan first
        log "Generating Terraform plan..."
        terraform plan -out=tfplan
        
        # Confirm before applying
        echo ""
        if [[ "$ENV" == "prod" ]]; then
            warning "You are about to deploy to PRODUCTION!"
            echo "Type 'deploy-prod' to confirm:"
            read -r confirmation
            if [[ "$confirmation" != "deploy-prod" ]]; then
                error "Operation cancelled"
                rm -f tfplan
                exit 1
            fi
        else
            read -p "Do you want to apply the $ENV environment? (y/N): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                error "Operation cancelled"
                rm -f tfplan
                exit 1
            fi
        fi
        
        # Apply the plan
        log "Applying Terraform configuration for $ENV..."
        if terraform apply tfplan; then
            rm -f tfplan
            success "$ENV environment deployed successfully!"
            
            # Show important outputs
            echo ""
            log "Deployment Summary:"
            terraform output deployment_summary 2>/dev/null || true
            
            echo ""
            log "Important URLs:"
            terraform output health_check_url 2>/dev/null || true
            terraform output app_url 2>/dev/null || true
            
            echo ""
            log "SSH Command:"
            terraform output ssh_command 2>/dev/null || true
            
            echo ""
            log "Next Steps:"
            echo "1. Test the health endpoint: make health-$ENV"
            echo "2. SSH to the instance: make ssh-$ENV"
            echo "3. Check application logs: ssh and run 'sudo journalctl -u fastapi-infra -f'"
            
        else
            rm -f tfplan
            error "Terraform apply failed"
            exit 1
        fi
        ;;
esac

log "Operation completed successfully!"
