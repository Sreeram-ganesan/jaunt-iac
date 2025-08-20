# Terraform Backend Configuration Template
# 
# This file is for local state only during initial backend (S3 bucket) creation.
# After the S3 bucket is created, uncomment and configure the backend block below
# to enable remote state. See README.md for details.
#
# Steps to enable remote backend:
# 1. First, run `terraform apply` without this backend configuration to create the S3 bucket
# 2. Uncomment the backend configuration below
# 3. Update the bucket name and other values to match your setup
# 4. Run `terraform init` to migrate the state to the remote backend
# 5. Confirm the migration when prompted

terraform {
  backend "s3" {
    bucket  = "jaunt-terraform-state-dev"
    key     = "backend/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

# Example with variables (after running terraform apply once):
# terraform {
#   backend "s3" {
#     bucket  = "fastapi-terraform-state-dev"
#     key     = "backend/terraform.tfstate"
#     region  = "us-west-2"
#     encrypt = true
#   }
# }