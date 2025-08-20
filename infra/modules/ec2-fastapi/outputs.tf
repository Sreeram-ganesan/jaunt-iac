output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.fastapi.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.fastapi.arn
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.fastapi.public_ip
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.fastapi.private_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.fastapi.public_dns
}

output "private_dns" {
  description = "Private DNS name of the EC2 instance"
  value       = aws_instance.fastapi.private_dns
}

output "elastic_ip" {
  description = "Elastic IP address (if created)"
  value       = var.create_elastic_ip ? aws_eip.fastapi[0].public_ip : ""
}

output "health_check_url" {
  description = "Health check URL for the FastAPI application"
  value       = "http://${var.create_elastic_ip ? aws_eip.fastapi[0].public_ip : aws_instance.fastapi.public_ip}:${var.app_port}/health"
}

output "app_url" {
  description = "Base URL for the FastAPI application"
  value       = "http://${var.create_elastic_ip ? aws_eip.fastapi[0].public_ip : aws_instance.fastapi.public_ip}:${var.app_port}"
}