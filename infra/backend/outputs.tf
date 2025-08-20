output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "backend_configuration" {
  description = "Backend configuration for use in other Terraform configurations"
  value = {
    bucket  = aws_s3_bucket.terraform_state.bucket
    key     = "terraform.tfstate" # This will be overridden per environment
    region  = var.aws_region
    encrypt = true
  }
}