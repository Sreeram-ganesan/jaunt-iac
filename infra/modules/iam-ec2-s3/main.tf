# IAM Module (iam-ec2-s3)
# Creates IAM role and instance profile for EC2 with S3 access

# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name               = "${var.project_name}-${var.environment}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ec2-role"
    Type = "IAM Role"
  })
}

# IAM Policy for S3 Full Access (MVP - will tighten later)
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Additional IAM Policy for Systems Manager (for potential debugging)
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile for EC2 attachment
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ec2-profile"
    Type = "IAM Instance Profile"
  })
}

# Custom IAM policy for specific S3 bucket access (if provided)
resource "aws_iam_policy" "s3_bucket_access" {
  count       = length(var.s3_bucket_names) > 0 ? 1 : 0
  name        = "${var.project_name}-${var.environment}-s3-bucket-access"
  description = "Custom S3 bucket access policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = concat(
          [for bucket in var.s3_bucket_names : "arn:aws:s3:::${bucket}"],
          [for bucket in var.s3_bucket_names : "arn:aws:s3:::${bucket}/*"]
        )
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-s3-bucket-policy"
    Type = "IAM Policy"
  })
}

# Attach custom S3 policy if provided
resource "aws_iam_role_policy_attachment" "s3_bucket_access" {
  count      = length(var.s3_bucket_names) > 0 ? 1 : 0
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_bucket_access[0].arn
}