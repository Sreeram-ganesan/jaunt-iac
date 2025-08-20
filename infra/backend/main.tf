# S3 Bucket for Terraform State Storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.environment
    Purpose     = "terraform-state-storage"
    Project     = "fastapi-infrastructure"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Note: This configuration uses S3 versioning for state management instead of DynamoDB locking.
# S3 Object Lock is not used here because Terraform requires the ability to delete lock files
# when operations complete, which Object Lock would prevent. For single-user or controlled
# environments, S3 versioning provides adequate protection against state corruption.
# For multi-user environments requiring strict locking, consider using DynamoDB locking.
