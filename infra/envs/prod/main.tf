# Production Environment - Main Configuration
# This file orchestrates all modules for the production environment

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

# Local values for common configuration
locals {
  environment = "prod"
  common_tags = merge(var.common_tags, {
    Environment = local.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
  })
}

# Network Module - VPC and Security Groups
module "network" {
  source = "../../modules/network-min"
  
  project_name = var.project_name
  environment  = local.environment
  common_tags  = local.common_tags
}

# IAM Module - EC2 Role with S3 Access
module "iam" {
  source = "../../modules/iam-ec2-s3"
  
  project_name    = var.project_name
  environment     = local.environment
  common_tags     = local.common_tags
  s3_bucket_names = var.s3_bucket_names
}

# RDS Module - PostgreSQL Database
module "rds" {
  source = "../../modules/rds-postgres"
  
  project_name    = var.project_name
  environment     = local.environment
  common_tags     = local.common_tags
  
  # RDS Configuration Choice
  use_existing_rds = var.use_existing_rds
  
  # Existing RDS Configuration (if use_existing_rds = true)
  existing_db_host     = var.existing_db_host
  existing_db_port     = var.existing_db_port
  existing_db_name     = var.existing_db_name
  existing_db_username = var.existing_db_username
  existing_db_password = var.existing_db_password
  
  # New RDS Configuration (if use_existing_rds = false)
  subnet_ids            = module.network.subnet_ids
  rds_security_group_id = module.network.rds_security_group_id
  
  engine_version            = var.rds_engine_version
  instance_class            = var.rds_instance_class
  allocated_storage         = var.rds_allocated_storage
  max_allocated_storage     = var.rds_max_allocated_storage
  db_name                   = var.db_name
  db_username               = var.db_username
  db_password               = var.db_password
  backup_retention_period   = var.rds_backup_retention_period
  skip_final_snapshot       = var.rds_skip_final_snapshot
  deletion_protection       = var.rds_deletion_protection
  multi_az                  = var.rds_multi_az
  
  store_password_in_secrets_manager = var.store_db_password_in_secrets_manager
}

# EC2 Module - FastAPI Application Server
module "ec2" {
  source = "../../modules/ec2-fastapi"
  
  project_name = var.project_name
  environment  = local.environment
  common_tags  = local.common_tags
  
  # EC2 Configuration
  instance_type                   = var.ec2_instance_type
  key_name                        = var.ec2_key_name
  subnet_id                       = module.network.subnet_ids[0]  # Use first available subnet
  security_group_ids              = module.network.security_group_ids
  iam_instance_profile_name       = module.iam.instance_profile_name
  associate_public_ip_address     = var.ec2_associate_public_ip
  create_elastic_ip              = var.ec2_create_elastic_ip
  
  # Storage Configuration
  root_volume_size      = var.ec2_root_volume_size
  root_volume_type      = var.ec2_root_volume_type
  root_volume_encrypted = var.ec2_root_volume_encrypted
  
  # Application Configuration
  app_repo_url    = var.fastapi_app_repo_url
  app_repo_branch = var.fastapi_app_repo_branch
  app_port        = var.fastapi_app_port
  log_level       = var.fastapi_log_level
  
  # Database Configuration
  db_host     = module.rds.db_host
  db_port     = module.rds.db_port
  db_name     = module.rds.db_name
  db_username = module.rds.db_username
  db_password = module.rds.db_password
  
  # API Configuration
  tavily_api_key = var.tavily_api_key
  gemini_api_key = var.gemini_api_key
  
  # S3 Configuration
  s3_bucket_name = var.s3_bucket_name
  
  depends_on = [module.network, module.iam, module.rds]
}