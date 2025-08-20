output "db_host" {
  description = "RDS instance hostname"
  value       = local.db_host
}

output "db_port" {
  description = "RDS instance port"
  value       = local.db_port
}

output "db_name" {
  description = "Database name"
  value       = local.db_name
}

output "db_username" {
  description = "Database username"
  value       = local.db_username
}

output "db_password" {
  description = "Database password"
  value       = var.use_existing_rds ? var.existing_db_password : (var.db_password != null ? var.db_password : try(random_password.db_password[0].result, null))
  sensitive   = true
}

output "db_connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = "postgresql://${local.db_username}@${local.db_host}:${local.db_port}/${local.db_name}"
  sensitive   = false
}

output "db_instance_arn" {
  description = "ARN of RDS instance (empty for existing RDS)"
  value       = var.use_existing_rds ? "" : try(aws_db_instance.postgres[0].arn, "")
}

output "db_instance_id" {
  description = "RDS instance identifier (empty for existing RDS)"
  value       = var.use_existing_rds ? "" : try(aws_db_instance.postgres[0].id, "")
}

output "db_subnet_group_name" {
  description = "Name of DB subnet group (empty for existing RDS)"
  value       = var.use_existing_rds ? "" : try(aws_db_subnet_group.postgres[0].name, "")
}

output "secrets_manager_secret_arn" {
  description = "ARN of Secrets Manager secret (if enabled)"
  value       = var.store_password_in_secrets_manager && !var.use_existing_rds ? try(aws_secretsmanager_secret.db_password[0].arn, "") : ""
}