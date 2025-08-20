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

# RDS Configuration Choice
variable "use_existing_rds" {
  description = "Whether to use an existing RDS instance (true) or create a new one (false)"
  type        = bool
  default     = false
}

# Existing RDS Configuration (when use_existing_rds = true)
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

# New RDS Configuration (when use_existing_rds = false)
variable "subnet_ids" {
  description = "List of subnet IDs for DB subnet group"
  type        = list(string)
  default     = []
}

variable "rds_security_group_id" {
  description = "Security group ID for RDS instance"
  type        = string
  default     = ""
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.2"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial allocated storage for RDS instance (GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for RDS instance (GB)"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type for RDS instance"
  type        = string
  default     = "gp2"
}

variable "storage_encrypted" {
  description = "Whether RDS storage should be encrypted"
  type        = bool
  default     = true
}

variable "db_name" {
  description = "Database name for new RDS instance"
  type        = string
  default     = "fastapi_db"
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

variable "backup_retention_period" {
  description = "Backup retention period (days)"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Maintenance window (UTC)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "delete_automated_backups" {
  description = "Whether to delete automated backups when DB is deleted"
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "Whether RDS instance should be publicly accessible"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Whether to enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot when deleting"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Whether to enable Performance Insights"
  type        = bool
  default     = false
}

variable "parameter_group_family" {
  description = "DB parameter group family"
  type        = string
  default     = "postgres16"
}

variable "store_password_in_secrets_manager" {
  description = "Whether to store password in AWS Secrets Manager"
  type        = bool
  default     = false
}