#!/bin/bash
set -e

# Deploy the development environment using Terraform

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="${SCRIPT_DIR}/../envs/dev"

echo "🚀 Deploying FastAPI Infrastructure: Development Environment"
echo "==========================================================="

cd "$ENV_DIR"

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
read -p "Do you want to apply the development environment? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Applying Terraform configuration for dev..."
    terraform apply -auto-approve
    echo "✅ Development environment deployed successfully!"
else
    echo "❌ Operation cancelled"
fi
