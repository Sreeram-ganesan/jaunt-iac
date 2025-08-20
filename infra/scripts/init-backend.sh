#!/bin/bash
set -e

# Initialize Terraform Backend Infrastructure
# This script helps set up the remote state backend for the FastAPI Infrastructure project

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="${SCRIPT_DIR}/../backend"

echo "🚀 FastAPI Infrastructure - Backend Initialization"
echo "================================================="

# Check if we're in the right directory
if [[ ! -d "$BACKEND_DIR" ]]; then
    echo "❌ Error: Backend directory not found at $BACKEND_DIR"
    exit 1
fi

cd "$BACKEND_DIR"

# Check if terraform.tfvars exists
if [[ ! -f "terraform.tfvars" ]]; then
    echo "⚠️  terraform.tfvars not found. Creating from example..."
    if [[ -f "terraform.tfvars.example" ]]; then
        cp terraform.tfvars.example terraform.tfvars
        echo "✅ Created terraform.tfvars from example"
        echo "📝 Please edit terraform.tfvars with your specific values before continuing"
        echo "   Key values to update:"
        echo "   - state_bucket_name (must be globally unique)"
        echo "   - aws_region (your preferred region)"
        echo "   - environment (dev/prod)"
        echo ""
        read -p "Press Enter after updating terraform.tfvars to continue..."
    else
        echo "❌ Error: terraform.tfvars.example not found"
        exit 1
    fi
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "❌ Error: AWS credentials not configured"
    echo "   Please configure AWS credentials using:"
    echo "   - aws configure"
    echo "   - AWS_PROFILE environment variable"
    echo "   - IAM roles, etc."
    exit 1
fi

echo "✅ AWS credentials configured"

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Validate configuration
echo "🔍 Validating Terraform configuration..."
terraform validate

# Show plan
echo "📋 Terraform plan:"
terraform plan

# Confirm before applying
echo ""
read -p "Do you want to create the backend infrastructure? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Creating backend infrastructure..."
    terraform apply -auto-approve
    
    echo ""
    echo "✅ Backend infrastructure created successfully!"
    echo "📄 Save these outputs for configuring remote backends in other projects:"
    echo ""
    terraform output
    
    echo ""
    echo "📝 Next steps:"
    echo "1. Use the S3 bucket in your environment configurations"
    echo "2. Configure backend blocks in your environment-specific Terraform files"
    echo "3. Run 'terraform init' in those directories to start using remote state"
    
else
    echo "❌ Operation cancelled"
fi