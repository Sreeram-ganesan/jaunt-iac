variable "state_bucket_name" {
  description = "Name of the S3 bucket for storing Terraform state"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.state_bucket_name))
    error_message = "S3 bucket name must be lowercase, contain only alphanumeric characters and hyphens, and not start or end with a hyphen."
  }
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
  default     = "terraform-state-lock"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.dynamodb_table_name))
    error_message = "DynamoDB table name must contain only alphanumeric characters, underscores, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}