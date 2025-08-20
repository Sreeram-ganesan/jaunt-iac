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

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance (if empty, latest Amazon Linux 2 will be used)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for EC2 instance"
  type        = list(string)
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address"
  type        = bool
  default     = true
}

variable "create_elastic_ip" {
  description = "Whether to create and associate an Elastic IP"
  type        = bool
  default     = false
}

# Storage Configuration
variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "root_volume_encrypted" {
  description = "Whether to encrypt root volume"
  type        = bool
  default     = true
}

# Application Configuration
variable "app_repo_url" {
  description = "FastAPI application repository URL"
  type        = string
  default     = "https://github.com/your-username/fastapi-app.git"
}

variable "app_repo_branch" {
  description = "FastAPI application repository branch"
  type        = string
  default     = "main"
}

variable "app_port" {
  description = "Port for FastAPI application"
  type        = number
  default     = 8000
}

variable "log_level" {
  description = "Log level for FastAPI application"
  type        = string
  default     = "info"
  validation {
    condition = contains(["debug", "info", "warning", "error", "critical"], var.log_level)
    error_message = "Log level must be one of: debug, info, warning, error, critical."
  }
}

# Database Configuration
variable "db_host" {
  description = "Database hostname"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

# API Configuration
variable "tavily_api_key" {
  description = "Tavily API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "gemini_api_key" {
  description = "Gemini API key"
  type        = string
  sensitive   = true
  default     = ""
}

# S3 Configuration
variable "s3_bucket_name" {
  description = "S3 bucket name for application data"
  type        = string
  default     = ""
}