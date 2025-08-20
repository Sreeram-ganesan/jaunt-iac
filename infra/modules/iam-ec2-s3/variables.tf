variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "fastapi-infra"
}

variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
  validation {
    condition = contains(["dev", "prod", "staging"], var.environment)
    error_message = "Environment must be one of: dev, prod, staging."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "FastAPI Infrastructure"
    ManagedBy = "Terraform"
  }
}

variable "s3_bucket_names" {
  description = "List of S3 bucket names for specific access (optional)"
  type        = list(string)
  default     = []
}