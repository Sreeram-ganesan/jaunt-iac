# RDS Postgres Module (rds-postgres)
# Supports both existing and new RDS instances based on use_existing_rds variable

locals {
  # Database connection details
  db_host = var.use_existing_rds ? var.existing_db_host : aws_db_instance.postgres[0].address
  db_port = var.use_existing_rds ? var.existing_db_port : aws_db_instance.postgres[0].port
  db_name = var.use_existing_rds ? var.existing_db_name : aws_db_instance.postgres[0].db_name
  db_username = var.use_existing_rds ? var.existing_db_username : aws_db_instance.postgres[0].username
}

# RDS Subnet Group (only created when creating new RDS)
resource "aws_db_subnet_group" "postgres" {
  count      = var.use_existing_rds ? 0 : 1
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
    Type = "DB Subnet Group"
  })
}

# RDS Parameter Group
resource "aws_db_parameter_group" "postgres" {
  count  = var.use_existing_rds ? 0 : 1
  family = var.parameter_group_family
  name   = "${var.project_name}-${var.environment}-postgres-params"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-postgres-params"
    Type = "DB Parameter Group"
  })
}

# RDS Instance (only created when use_existing_rds is false)
resource "aws_db_instance" "postgres" {
  count = var.use_existing_rds ? 0 : 1

  # Database Configuration
  identifier     = "${var.project_name}-${var.environment}-postgres"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Database Settings
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type         = var.storage_type
  storage_encrypted    = var.storage_encrypted

  # Database Credentials
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password  # Consider using AWS Secrets Manager in production

  # Network & Security
  vpc_security_group_ids = [var.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.postgres[0].name
  parameter_group_name   = aws_db_parameter_group.postgres[0].name

  # Backup & Maintenance
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  delete_automated_backups = var.delete_automated_backups

  # Other Settings
  publicly_accessible = var.publicly_accessible
  multi_az            = var.multi_az
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection

  # Performance Insights (for monitoring)
  performance_insights_enabled = var.performance_insights_enabled

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-postgres"
    Type        = "RDS Instance"
    Environment = var.environment
  })
}

# Random password for RDS (only when creating new RDS and no password provided)
resource "random_password" "db_password" {
  count   = var.use_existing_rds || var.db_password != null ? 0 : 1
  length  = 16
  special = true
}

# AWS Secrets Manager secret for DB password (recommended for production)
resource "aws_secretsmanager_secret" "db_password" {
  count       = var.use_existing_rds || var.store_password_in_secrets_manager == false ? 0 : 1
  name        = "${var.project_name}/${var.environment}/rds/password"
  description = "RDS PostgreSQL password for ${var.project_name}-${var.environment}"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-rds-password"
    Type = "Secrets Manager Secret"
  })
}

resource "aws_secretsmanager_secret_version" "db_password" {
  count         = var.use_existing_rds || var.store_password_in_secrets_manager == false ? 0 : 1
  secret_id     = aws_secretsmanager_secret.db_password[0].id
  secret_string = var.db_password != null ? var.db_password : random_password.db_password[0].result
}