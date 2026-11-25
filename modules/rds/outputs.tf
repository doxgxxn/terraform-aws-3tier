output "address" {
  description = "DNS address of the database instance"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "Database port"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Initial database name"
  value       = aws_db_instance.this.db_name
}

output "username" {
  description = "Master username"
  value       = aws_db_instance.this.username
}

output "password_ssm_parameter_arn" {
  description = "ARN of the SSM SecureString holding the master password (inject via ECS secrets)"
  value       = aws_ssm_parameter.db_password.arn
}

output "db_security_group_id" {
  description = "Security group ID of the database"
  value       = aws_security_group.db.id
}
