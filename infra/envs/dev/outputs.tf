# Development Environment - Outputs
# Export important values from the development deployment

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

# Quick Test Commands
output "test_commands" {
  description = "Commands to test the deployed infrastructure"
  value = {
    health_check = "curl ${module.ec2.health_check_url}"
    api_test     = "curl ${module.ec2.app_url}/api/test"
    logs         = "ssh -i ~/.ssh/${var.ec2_key_name}.pem ec2-user@${module.ec2.public_ip} 'sudo journalctl -u fastapi-infra -f'"
  }
}

# Environment Summary
output "deployment_summary" {
  description = "Summary of the deployed infrastructure"
  value = {
    environment     = "dev"
    project_name    = var.project_name
    aws_region      = var.aws_region
    instance_type   = var.ec2_instance_type
    rds_mode        = var.use_existing_rds ? "existing" : "new"
    app_port        = var.fastapi_app_port
    public_access   = var.ec2_associate_public_ip
  }
}