output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets (ALB tier)"
  value       = aws_subnet.public[*].id
}

output "app_subnet_ids" {
  description = "IDs of the private app subnets (ECS tier)"
  value       = aws_subnet.app[*].id
}

output "db_subnet_ids" {
  description = "IDs of the private db subnets (RDS tier)"
  value       = aws_subnet.db[*].id
}

output "azs" {
  description = "Availability zones in use"
  value       = local.azs
}
