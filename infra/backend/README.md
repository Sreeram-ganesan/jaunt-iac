# Terraform Remote State Backend Configuration

This directory contains the Terraform configuration to set up remote state backend infrastructure for the FastAPI project using AWS S3.

## Overview

The remote state backend consists of:
- **S3 Bucket**: Stores Terraform state files with versioning and encryption

**Note on State Locking**: This configuration uses S3 versioning instead of DynamoDB locking for simplicity. While S3 Object Lock was considered, it's not suitable for Terraform state locking because Terraform needs to delete lock files when operations complete. For single-user or controlled environments, S3 versioning provides adequate protection. For multi-user environments requiring strict locking, consider adding DynamoDB locking.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- Permissions to create S3 buckets in your AWS account

## Quick Setup

### 1. Configure Variables

Copy the example variables file and customize it:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 2. Initialize and Create Backend Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 3. Migrate to Remote Backend (Optional)

After creating the backend infrastructure, you can migrate this configuration to use remote state:

1. Note the S3 bucket name and DynamoDB table name from the output
2. Edit `backend.tf` and uncomment the backend configuration
3. Update the bucket name in the backend configuration
4. Re-initialize Terraform:

```bash
terraform init
# Terraform will ask if you want to copy existing state to the new backend
# Type 'yes' to migrate
```

## Usage in Other Configurations

Once the backend infrastructure is created, you can use it in other Terraform configurations:

```hcl
terraform {
  backend "s3" {
    bucket  = "your-terraform-state-bucket"
    key     = "path/to/terraform.tfstate"  # Unique for each configuration
    region  = "us-west-2"
    encrypt = true
  }
}
```

## State Organization

Recommended state key patterns:
- `backend/terraform.tfstate` - For backend infrastructure itself
- `environments/dev/terraform.tfstate` - For development environment
- `environments/prod/terraform.tfstate` - For production environment

## Important Notes

- The S3 bucket name must be globally unique across all AWS accounts
- Enable versioning and encryption for state files security

## Outputs

This configuration provides the following outputs:
- `s3_bucket_name` - Name of the created S3 bucket
- `s3_bucket_arn` - ARN of the S3 bucket
- `backend_configuration` - Complete backend configuration for reference

## Cleanup

To destroy the backend infrastructure:

```bash
terraform destroy
```

**Warning**: Only destroy the backend infrastructure after ensuring all other Terraform configurations are no longer using it, or their states have been migrated elsewhere.