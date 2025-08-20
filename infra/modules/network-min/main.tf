# Network Module (network-min)
# Provides VPC configuration and security groups for FastAPI infrastructure

# Use default VPC for MVP
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group for SSH access
resource "aws_security_group" "ssh" {
  name_prefix = "${var.project_name}-${var.environment}-ssh"
  description = "Security group for SSH access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting this in production
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ssh-sg"
    Type = "SSH Security Group"
  })
}

# Security Group for FastAPI HTTP access
resource "aws_security_group" "http" {
  name_prefix = "${var.project_name}-${var.environment}-http"
  description = "Security group for FastAPI HTTP access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "FastAPI HTTP"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-http-sg"
    Type = "HTTP Security Group"
  })
}

# Security Group for outbound internet access (APIs)
resource "aws_security_group" "outbound" {
  name_prefix = "${var.project_name}-${var.environment}-outbound"
  description = "Security group for outbound internet access (Tavily/Gemini APIs)"
  vpc_id      = data.aws_vpc.default.id

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS for API calls
  egress {
    description = "HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP outbound
  egress {
    description = "HTTP outbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-outbound-sg"
    Type = "Outbound Security Group"
  })
}

# Security Group for RDS access (used by EC2 instances)
resource "aws_security_group" "rds_access" {
  name_prefix = "${var.project_name}-${var.environment}-rds-access"
  description = "Security group for RDS database access from EC2"
  vpc_id      = data.aws_vpc.default.id

  egress {
    description = "RDS PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-rds-access-sg"
    Type = "RDS Access Security Group"
  })
}

# Security Group for RDS database (allows access from EC2)
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds"
  description = "Security group for RDS database"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "PostgreSQL from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rds_access.id]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-rds-sg"
    Type = "RDS Security Group"
  })
}