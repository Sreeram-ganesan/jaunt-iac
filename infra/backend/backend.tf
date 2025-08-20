# Terraform Backend Configuration Template
# 
# This file should be uncommented and configured AFTER the initial backend
# infrastructure (S3 bucket) has been created.
#
# Steps to enable remote backend:
# 1. First, run `terraform apply` without this backend configuration to create the S3 bucket
# 2. Uncomment the backend configuration below
# 3. Update the bucket name and other values to match your setup
# 4. Run `terraform init` to migrate the state to the remote backend
# 5. Confirm the migration when prompted

# terraform {
#   backend "s3" {
#     bucket  = "your-terraform-state-bucket-name"
#     key     = "backend/terraform.tfstate"
#     region  = "us-west-2"
#     encrypt = true
#   }
# }

# Example with variables (after running terraform apply once):
# terraform {
#   backend "s3" {
#     bucket  = "fastapi-terraform-state-dev"
#     key     = "backend/terraform.tfstate"
#     region  = "us-west-2"
#     encrypt = true
#   }
# }