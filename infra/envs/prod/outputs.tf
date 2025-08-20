# Production Environment - Outputs
# Export important values from the production deployment

# Network Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = module.network.subnet_ids
}

output "security_group_ids" {
  description = "List of security group IDs"
  value = {
    ssh      = module.network.ssh_security_group_id
    http     = module.network.http_security_group_id
    outbound = module.network.outbound_security_group_id
    rds      = module.network.rds_security_group_id
  }
}

# IAM Outputs
output "iam_role_arn" {
  description = "ARN of the IAM role for EC2"
  value       = module.iam.iam_role_arn
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = module.iam.instance_profile_name
}

# RDS Outputs
output "db_host" {
  description = "RDS instance hostname"
  value       = module.rds.db_host
}

output "db_port" {
  description = "RDS instance port"
  value       = module.rds.db_port
}

output "db_name" {
  description = "Database name"
  value       = module.rds.db_name
}

output "db_username" {
  description = "Database username"
  value       = module.rds.db_username
}

output "db_connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = module.rds.db_connection_string
  sensitive   = false
}

output "secrets_manager_secret_arn" {
  description = "ARN of Secrets Manager secret for database password"
  value       = module.rds.secrets_manager_secret_arn
}

# EC2 Outputs
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.public_ip
}

output "ec2_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.ec2.private_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = module.ec2.public_dns
}

output "elastic_ip" {
  description = "Elastic IP address (if created)"
  value       = module.ec2.elastic_ip
}

# Application URLs
output "health_check_url" {
  description = "Health check URL for the FastAPI application"
  value       = module.ec2.health_check_url
}

output "app_url" {
  description = "Base URL for the FastAPI application"
  value       = module.ec2.app_url
}

# SSH Command
output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ~/.ssh/${var.ec2_key_name}.pem ec2-user@${module.ec2.public_ip}"
}

# Production Monitoring Commands
output "monitoring_commands" {
  description = "Commands for production monitoring"
  value = {
    health_check     = "curl ${module.ec2.health_check_url}"
    api_test         = "curl ${module.ec2.app_url}/api/test"
    service_status   = "ssh -i ~/.ssh/${var.ec2_key_name}.pem ec2-user@${module.ec2.public_ip} 'sudo systemctl status fastapi-infra'"
    application_logs = "ssh -i ~/.ssh/${var.ec2_key_name}.pem ec2-user@${module.ec2.public_ip} 'sudo journalctl -u fastapi-infra -n 100'"
    system_metrics   = "ssh -i ~/.ssh/${var.ec2_key_name}.pem ec2-user@${module.ec2.public_ip} 'top -n 1'"
  }
}

# Environment Summary
output "deployment_summary" {
  description = "Summary of the deployed production infrastructure"
  value = {
    environment           = "prod"
    project_name          = var.project_name
    aws_region            = var.aws_region
    instance_type         = var.ec2_instance_type
    rds_instance_class    = var.use_existing_rds ? "existing" : var.rds_instance_class
    rds_mode              = var.use_existing_rds ? "existing" : "new"
    multi_az_enabled      = var.use_existing_rds ? "unknown" : var.rds_multi_az
    deletion_protection   = var.use_existing_rds ? "unknown" : var.rds_deletion_protection
    backup_retention_days = var.use_existing_rds ? "unknown" : var.rds_backup_retention_period
    app_port              = var.fastapi_app_port
    elastic_ip_enabled    = var.ec2_create_elastic_ip
    secrets_manager       = var.store_db_password_in_secrets_manager
  }
}

# Security Checklist for Production
output "security_checklist" {
  description = "Security considerations for production deployment"
  value = {
    rds_encrypted            = "Verify RDS encryption is enabled"
    ebs_encrypted            = var.ec2_root_volume_encrypted
    secrets_manager_enabled  = var.store_db_password_in_secrets_manager
    deletion_protection      = var.use_existing_rds ? "Review existing RDS settings" : var.rds_deletion_protection
    backup_enabled           = var.use_existing_rds ? "Review existing RDS settings" : "Enabled with ${var.rds_backup_retention_period} days retention"
    multi_az                 = var.use_existing_rds ? "Review existing RDS settings" : var.rds_multi_az
    security_groups          = "Review and restrict SSH access to specific IP ranges"
    api_keys_management      = "Ensure API keys are properly managed and rotated"
    monitoring               = "Consider enabling CloudWatch monitoring and alerting"
  }
}