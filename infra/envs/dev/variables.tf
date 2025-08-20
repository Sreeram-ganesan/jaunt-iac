# Development Environment - Variables
# Define all variables for the development environment

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "fastapi-infra"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "FastAPI Infrastructure"
    ManagedBy = "Terraform"
  }
}

# RDS Configuration
variable "use_existing_rds" {
  description = "Whether to use an existing RDS instance (true) or create a new one (false)"
  type        = bool
  default     = false
}

# Existing RDS Variables (when use_existing_rds = true)
variable "existing_db_host" {
  description = "Hostname of existing RDS instance"
  type        = string
  default     = null
}

variable "existing_db_port" {
  description = "Port of existing RDS instance"
  type        = number
  default     = 5432
}

variable "existing_db_name" {
  description = "Database name of existing RDS instance"
  type        = string
  default     = null
}

variable "existing_db_username" {
  description = "Username for existing RDS instance"
  type        = string
  default     = null
}

variable "existing_db_password" {
  description = "Password for existing RDS instance"
  type        = string
  default     = null
  sensitive   = true
}

# New RDS Variables (when use_existing_rds = false)
variable "rds_engine_version" {
  description = "PostgreSQL engine version for new RDS instance"
  type        = string
  default     = "16.2"
}

variable "rds_instance_class" {
  description = "RDS instance class for new RDS instance"
  type        = string
  default     = "db.t3.micro"  # Free tier eligible
}

variable "rds_allocated_storage" {
  description = "Initial allocated storage for new RDS instance (GB)"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Maximum allocated storage for new RDS instance (GB)"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Database name for new RDS instance"
  type        = string
  default     = "fastapi_dev"
}

variable "db_username" {
  description = "Database username for new RDS instance"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Database password for new RDS instance (if null, random password will be generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "rds_backup_retention_period" {
  description = "Backup retention period for new RDS instance (days)"
  type        = number
  default     = 1  # Minimal for dev
}

variable "rds_skip_final_snapshot" {
  description = "Whether to skip final snapshot when deleting RDS instance"
  type        = bool
  default     = true  # Skip for dev environment
}

variable "rds_deletion_protection" {
  description = "Whether to enable deletion protection for RDS instance"
  type        = bool
  default     = false  # Disabled for dev environment
}

variable "rds_multi_az" {
  description = "Whether to enable Multi-AZ deployment for RDS instance"
  type        = bool
  default     = false  # Disabled for dev (cost optimization)
}

variable "store_db_password_in_secrets_manager" {
  description = "Whether to store database password in AWS Secrets Manager"
  type        = bool
  default     = false  # Simplified for dev
}

# EC2 Configuration
variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"  # Free tier eligible
}

variable "ec2_key_name" {
  description = "EC2 Key Pair name for SSH access (must exist in AWS)"
  type        = string
}

variable "ec2_associate_public_ip" {
  description = "Whether to associate a public IP address with EC2 instance"
  type        = bool
  default     = true
}

variable "ec2_create_elastic_ip" {
  description = "Whether to create and associate an Elastic IP with EC2 instance"
  type        = bool
  default     = false  # Not needed for dev
}

variable "ec2_root_volume_size" {
  description = "Root volume size in GB for EC2 instance"
  type        = number
  default     = 20
}

variable "ec2_root_volume_type" {
  description = "Root volume type for EC2 instance"
  type        = string
  default     = "gp3"
}

variable "ec2_root_volume_encrypted" {
  description = "Whether to encrypt root volume of EC2 instance"
  type        = bool
  default     = true
}

# FastAPI Application Configuration
variable "fastapi_app_repo_url" {
  description = "FastAPI application repository URL"
  type        = string
  default     = "https://github.com/your-username/fastapi-app.git"
}

variable "fastapi_app_repo_branch" {
  description = "FastAPI application repository branch"
  type        = string
  default     = "main"
}

variable "fastapi_app_port" {
  description = "Port for FastAPI application"
  type        = number
  default     = 8000
}

variable "fastapi_log_level" {
  description = "Log level for FastAPI application"
  type        = string
  default     = "info"
  validation {
    condition = contains(["debug", "info", "warning", "error", "critical"], var.fastapi_log_level)
    error_message = "Log level must be one of: debug, info, warning, error, critical."
  }
}

# API Keys (External Services)
variable "tavily_api_key" {
  description = "Tavily API key for external service integration"
  type        = string
  default     = ""
  sensitive   = true
}

variable "gemini_api_key" {
  description = "Gemini API key for external service integration"
  type        = string
  default     = ""
  sensitive   = true
}

# S3 Configuration
variable "s3_bucket_name" {
  description = "S3 bucket name for application data"
  type        = string
  default     = ""
}

variable "s3_bucket_names" {
  description = "List of S3 bucket names for specific IAM access (optional)"
  type        = list(string)
  default     = []
}