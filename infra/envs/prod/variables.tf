# Production Environment - Variables
# Define all variables for the production environment with production-ready defaults

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

# New RDS Variables (when use_existing_rds = false) - Production Defaults
variable "rds_engine_version" {
  description = "PostgreSQL engine version for new RDS instance"
  type        = string
  default     = "16.2"
}

variable "rds_instance_class" {
  description = "RDS instance class for new RDS instance"
  type        = string
  default     = "db.t3.small"  # Better performance for production
}

variable "rds_allocated_storage" {
  description = "Initial allocated storage for new RDS instance (GB)"
  type        = number
  default     = 100  # Larger initial storage for production
}

variable "rds_max_allocated_storage" {
  description = "Maximum allocated storage for new RDS instance (GB)"
  type        = number
  default     = 500  # Higher maximum for production scaling
}

variable "db_name" {
  description = "Database name for new RDS instance"
  type        = string
  default     = "fastapi_prod"
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
  default     = 7  # Production backup retention
}

variable "rds_skip_final_snapshot" {
  description = "Whether to skip final snapshot when deleting RDS instance"
  type        = bool
  default     = false  # Take final snapshot in production
}

variable "rds_deletion_protection" {
  description = "Whether to enable deletion protection for RDS instance"
  type        = bool
  default     = true  # Enable protection in production
}

variable "rds_multi_az" {
  description = "Whether to enable Multi-AZ deployment for RDS instance"
  type        = bool
  default     = true  # Enable for production high availability
}

variable "store_db_password_in_secrets_manager" {
  description = "Whether to store database password in AWS Secrets Manager"
  type        = bool
  default     = true  # Use Secrets Manager in production
}

# EC2 Configuration - Production Defaults
variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"  # Better performance for production
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
  default     = true  # Recommended for production
}

variable "ec2_root_volume_size" {
  description = "Root volume size in GB for EC2 instance"
  type        = number
  default     = 50  # Larger for production
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
  default     = "warning"  # Less verbose for production
  validation {
    condition = contains(["debug", "info", "warning", "error", "critical"], var.fastapi_log_level)
    error_message = "Log level must be one of: debug, info, warning, error, critical."
  }
}

# API Keys (External Services) - Required for production
variable "tavily_api_key" {
  description = "Tavily API key for external service integration"
  type        = string
  sensitive   = true
}

variable "gemini_api_key" {
  description = "Gemini API key for external service integration"
  type        = string
  sensitive   = true
}

# S3 Configuration
variable "s3_bucket_name" {
  description = "S3 bucket name for application data"
  type        = string
}

variable "s3_bucket_names" {
  description = "List of S3 bucket names for specific IAM access"
  type        = list(string)
  default     = []
}