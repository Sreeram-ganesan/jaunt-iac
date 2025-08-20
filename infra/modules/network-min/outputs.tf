output "vpc_id" {
  description = "ID of the default VPC"
  value       = data.aws_vpc.default.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the default VPC"
  value       = data.aws_vpc.default.cidr_block
}

output "subnet_ids" {
  description = "List of subnet IDs in the default VPC"
  value       = data.aws_subnets.default.ids
}

output "ssh_security_group_id" {
  description = "ID of the SSH security group"
  value       = aws_security_group.ssh.id
}

output "http_security_group_id" {
  description = "ID of the HTTP security group"
  value       = aws_security_group.http.id
}

output "outbound_security_group_id" {
  description = "ID of the outbound security group"
  value       = aws_security_group.outbound.id
}

output "rds_access_security_group_id" {
  description = "ID of the RDS access security group (for EC2 instances)"
  value       = aws_security_group.rds_access.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group (for database)"
  value       = aws_security_group.rds.id
}

output "security_group_ids" {
  description = "List of all security group IDs for EC2 instances"
  value = [
    aws_security_group.ssh.id,
    aws_security_group.http.id,
    aws_security_group.outbound.id,
    aws_security_group.rds_access.id
  ]
}