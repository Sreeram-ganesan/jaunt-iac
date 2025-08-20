# EC2 FastAPI Module (ec2-fastapi)
# Creates EC2 instance for FastAPI deployment with user data script

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Generate user data script for EC2 initialization
locals {
  user_data = templatefile("${path.module}/user_data.sh", {
    project_name     = var.project_name
    environment      = var.environment
    app_repo_url     = var.app_repo_url
    app_repo_branch  = var.app_repo_branch
    
    # Database configuration
    db_host     = var.db_host
    db_port     = var.db_port
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    
    # API configuration
    tavily_api_key = var.tavily_api_key
    gemini_api_key = var.gemini_api_key
    
    # S3 configuration
    s3_bucket_name = var.s3_bucket_name
    
    # App configuration
    app_port        = var.app_port
    log_level      = var.log_level
    fastapi_env    = var.environment
  })
}

# EC2 Instance for FastAPI
resource "aws_instance" "fastapi" {
  ami           = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Network configuration
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip_address

  # IAM configuration
  iam_instance_profile = var.iam_instance_profile_name

  # User data for application deployment
  user_data = base64encode(local.user_data)

  # Storage
  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    encrypted   = var.root_volume_encrypted
    
    tags = merge(var.common_tags, {
      Name = "${var.project_name}-${var.environment}-root-volume"
      Type = "EBS Volume"
    })
  }

  # Instance metadata options
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-fastapi"
    Type        = "EC2 Instance"
    Application = "FastAPI"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP (optional)
resource "aws_eip" "fastapi" {
  count    = var.create_elastic_ip ? 1 : 0
  instance = aws_instance.fastapi.id
  domain   = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-fastapi-eip"
    Type = "Elastic IP"
  })

  depends_on = [aws_instance.fastapi]
}